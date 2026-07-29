#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "yaml"
require_relative "../lib/publication_citations"

ROOT = File.expand_path("..", __dir__)

def load_yaml(name)
  YAML.safe_load(
    File.read(File.join(ROOT, "_data", name)),
    permitted_classes: [Date],
    aliases: false
  )
end

def balanced_bibtex_braces?(value)
  depth = 0
  escaped = false

  value.each_char do |character|
    if escaped
      escaped = false
      next
    end
    if character == "\\"
      escaped = true
    elsif character == "{"
      depth += 1
    elsif character == "}"
      depth -= 1
      return false if depth.negative?
    end
  end

  depth.zero?
end

publications = load_yaml("publications.yml").fetch("entries")
config = load_yaml("publication-citation.yml")
people = load_yaml("publication-people.yml")
cases = load_yaml("publication-citation-cases.yml")
generator = PublicationCitations::Generator.new(people: people, site_url: config["site_url"])
entries_by_id = publications.to_h { |entry| [entry.fetch("id"), entry] }
styles = config.fetch("planned_styles").map { |style| style.fetch("id") }
failures = []

cases.each do |citation_case|
  entry = entries_by_id.fetch(citation_case.fetch("publication_id"))
  styles.each do |style|
    actual = generator.generate(entry, style)
    expected = citation_case.fetch("expected").fetch(style)
    failures << "#{citation_case.fetch('id')} / #{style}\nEXPECTED:\n#{expected}\nACTUAL:\n#{actual}" unless actual == expected
  end
end

scope = config.fetch("initial_scope")
eligible = publications.select do |entry|
  scope.fetch("categories").include?(entry["category"]) &&
    scope.fetch("schema_types").include?(entry["schema_type"]) &&
    scope.fetch("statuses").include?(entry["status"])
end

eligible.each do |entry|
  styles.each do |style|
    output = generator.generate(entry, style)
    failures << "#{entry.fetch('id')} / #{style}: empty output" if output.strip.empty?
    failures << "#{entry.fetch('id')} / #{style}: leaked blank value" if output.match?(/\b(nil|null)\b/i)
    if style == "bibtex" && !balanced_bibtex_braces?(output)
      failures << "#{entry.fetch('id')} / #{style}: unbalanced braces"
    end
  rescue PublicationCitations::Error => e
    failures << "#{entry.fetch('id')} / #{style}: #{e.message}"
  end
  %w[chicago-notes-bibliography mla-9].each do |style|
    html = generator.generate(entry, style, format: :html)
    type = entry.fetch("schema_type")
    cite_optional = type == "CreativeWork" ||
                    (style == "chicago-notes-bibliography" && %w[WebSite VideoObject].include?(type))
    unless cite_optional || html.include?("<cite>")
      failures << "#{entry.fetch('id')} / #{style}: missing semantic cite element"
    end
  end

  ris = generator.generate(entry, "ris")
  failures << "#{entry.fetch('id')} / RIS: missing type header" unless ris.start_with?("TY  - ")
  failures << "#{entry.fetch('id')} / RIS: missing record terminator" unless ris.rstrip.end_with?("ER  -")
  failures << "#{entry.fetch('id')} / RIS: embedded bare LF" if ris.gsub("\r\n", "").include?("\n")

  begin
    csl = JSON.parse(generator.generate(entry, "csl-json"))
    failures << "#{entry.fetch('id')} / CSL-JSON: missing title" unless csl["title"] == entry["title"]
    failures << "#{entry.fetch('id')} / CSL-JSON: missing type" if csl["type"].to_s.empty?
    failures << "#{entry.fetch('id')} / CSL-JSON: DOI contains resolver URL" if csl["DOI"].to_s.start_with?("http")
  rescue JSON::ParserError => e
    failures << "#{entry.fetch('id')} / CSL-JSON: #{e.message}"
  end
end

key_map = generator.citation_keys(eligible)
keys = key_map.values
duplicate_keys = keys.tally.select { |_key, count| count > 1 }.keys
failures << "duplicate BibTeX keys: #{duplicate_keys.join(', ')}" unless duplicate_keys.empty?

complex = generator.generate(
  {
    "schema_type" => "Chapter",
    "title" => "Name Test",
    "authors" => [{ "name" => "Edgardo da Silva" }],
    "year" => 2026,
    "status" => "published",
    "book" => {
      "title" => "Test Book",
      "editors" => [{ "name" => "Max José Dreysse Passos de Carvalho" }]
    },
    "publisher" => { "name" => "Test Press" },
    "links" => []
  },
  "chicago-notes-bibliography"
)
unless complex.start_with?("da Silva, Edgardo.") && complex.include?("edited by Max José Dreysse Passos de Carvalho")
  failures << "complex name parts were not preserved"
end

collision_entries = [
  {
    "id" => "collision-a", "schema_type" => "Book", "title" => "Same Title",
    "citation_key" => "woell2026same",
    "authors" => [{ "name" => "Steffen Wöll" }], "year" => 2026
  },
  {
    "id" => "collision-b", "schema_type" => "Book", "title" => "Same Title",
    "citation_key" => "woell2026same",
    "authors" => [{ "name" => "Steffen Wöll" }], "year" => 2026
  }
]
collision_keys = generator.citation_keys(collision_entries)
unless collision_keys == { "collision-a" => "woell2026samea", "collision-b" => "woell2026sameb" }
  failures << "BibTeX key collisions are not resolved deterministically"
end

forthcoming = eligible.find { |entry| entry["status"] == "forthcoming" }
forthcoming_bibtex = generator.generate(forthcoming, "bibtex")
unless forthcoming_bibtex.include?("year = {#{forthcoming['expected_year']}}") &&
       forthcoming_bibtex.include?("note = {Forthcoming}")
  failures << "forthcoming BibTeX status fallback is incomplete"
end

quality_cases = {
  "two-author Chicago punctuation" => lambda {
    entry = entries_by_id.fetch("publication-periphere-raume-in-der-amerikanistik")
    generator.generate(entry, "chicago-notes-bibliography").start_with?("Wöll, Steffen, and Gabriele Pisarz-Ramirez.")
  },
  "MLA et al. for more than two authors" => lambda {
    entry = entries_by_id.fetch("publication-introduction-conceptualizing-archipelagic-mobilities")
    generator.generate(entry, "mla-9").start_with?("Wöll, Steffen, et al.")
  },
  "MLA et al. for multiple editors" => lambda {
    entry = entries_by_id.fetch("publication-true-places-never-are-navigating-trans-oceanic-imaginations-in-moby-dick")
    generator.generate(entry, "mla-9").include?("edited by Edgardo da Silva et al.")
  },
  "nested quotation marks" => lambda {
    entry = entries_by_id.fetch("publication-then-i-started-for-the-mountains-retracing-louisiana-s-human-geographies-across-five-remar")
    generator.generate(entry, "chicago-notes-bibliography").include?("“‘Then I Started for the Mountains’:")
  },
  "URL fallback without DOI" => lambda {
    entry = entries_by_id.fetch("publication-beyond-the-artifact-unfolding-medieval-algorithmic-and-unruly-lives-of-maps")
    generator.generate(entry, "mla-9").include?("https://journals.lib.unb.ca/")
  },
  "entry without DOI or URL" => lambda {
    !generator.generate(forthcoming, "chicago-notes-bibliography").include?("http")
  },
  "in-press BibTeX status" => lambda {
    entry = entries_by_id.fetch("publication-mug-shots-and-passport-photography")
    output = generator.generate(entry, "bibtex")
    output.include?("year = {2026}") && output.include?("note = {In press}")
  },
  "roman page range in BibTeX" => lambda {
    entry = entries_by_id.fetch("publication-american-health")
    generator.generate(entry, "bibtex").include?("pages = {v--viii}")
  },
  "BibTeX special-character escaping" => lambda {
    entry = entries_by_id.fetch("publication-playing-the-race-card-lovecraftian-play-spaces-and-tentacular-sympoiesis-in-the-arkham-hor")
    generator.generate(entry, "bibtex").include?("10.1007/978-3-031-13765-5\\_19")
  },
  "BibTeX title capitalization protection" => lambda {
    entry = entries_by_id.fetch("publication-global-imaginations-of-u-s-imperialism-1898-1945")
    generator.generate(entry, "bibtex").include?("title = {{Global Imaginations of U.S. Imperialism, 1898–1945}}")
  },
  "semantic HTML escaping" => lambda {
    synthetic = entries_by_id.fetch("publication-unmasking-maps-unmaking-empire-towards-an-archipelagic-cartography").merge(
      "title" => "Maps & <Empire>"
    )
    output = generator.generate(synthetic, "chicago-notes-bibliography", format: :html)
    output.include?("Maps &amp; &lt;Empire&gt;") && !output.include?("<Empire>")
  },
  "edited issue uses conservative BibTeX type" => lambda {
    entry = entries_by_id.fetch("publication-archipelagic-spaces-and-im-mobilities")
    generator.generate(entry, "bibtex").start_with?("@misc{")
  },
  "working paper uses techreport fields" => lambda {
    entry = entries_by_id.fetch("publication-spatial-fictions-imagining-trans-national-space-in-the-southern-and-western-peripheries-of")
    output = generator.generate(entry, "bibtex")
    output.start_with?("@techreport{") &&
      output.include?("type = {SFB 1199 Working Paper}") &&
      output.include?("number = {10}")
  },
  "review uses article BibTeX type" => lambda {
    entry = entries_by_id.fetch("publication-review-of-imperial-infrastructure-and-spatial-resistance-in-colonial-literature-1880-1930-")
    generator.generate(entry, "bibtex").start_with?("@article{")
  },
  "forthcoming review omits unknown year" => lambda {
    entry = entries_by_id.fetch("publication-review-of-colonial-ports-global-trade-and-the-roots-of-the-american-revolution-by-jeremy-l")
    chicago = generator.generate(entry, "chicago-notes-bibliography")
    bibtex = generator.generate(entry, "bibtex")
    chicago.end_with?("Forthcoming.") &&
      !chicago.include?("()") &&
      !bibtex.include?("year =") &&
      bibtex.include?("note = {Forthcoming}")
  },
  "review HTML emphasizes reviewed title" => lambda {
    entry = entries_by_id.fetch("publication-review-of-the-creole-archipelago-race-and-borders-in-the-colonial-caribbean-by-tessa-murph")
    output = generator.generate(entry, "mla-9", format: :html)
    output.include?("<cite>The Creole Archipelago: Race and Borders in the Colonial Caribbean</cite>")
  },
  "RIS type mapping covers all supported types" => lambda {
    expected = {
      "Book" => "BOOK", "PublicationIssue" => "SER", "ScholarlyArticle" => "JOUR",
      "Chapter" => "CHAP", "Report" => "RPRT", "Review" => "JOUR",
      "Dataset" => "DATA", "DigitalDocument" => "ELEC", "Map" => "MAP",
      "WebSite" => "ELEC", "Article" => "JOUR", "BlogPosting" => "BLOG",
      "VideoObject" => "VIDEO"
    }
    expected.all? do |schema_type, ris_type|
      entry = eligible.find { |candidate| candidate["schema_type"] == schema_type }
      generator.generate(entry, "ris").start_with?("TY  - #{ris_type}\r\n")
    end
  },
  "CSL type mapping covers all supported types" => lambda {
    expected = {
      "Book" => "book", "PublicationIssue" => "periodical",
      "ScholarlyArticle" => "article-journal", "Chapter" => "chapter",
      "Report" => "report", "Review" => "review", "Dataset" => "dataset",
      "DigitalDocument" => "document", "Map" => "map", "WebSite" => "webpage",
      "Article" => "article", "BlogPosting" => "post-weblog",
      "VideoObject" => "motion_picture"
    }
    expected.all? do |schema_type, csl_type|
      entry = eligible.find { |candidate| candidate["schema_type"] == schema_type }
      JSON.parse(generator.generate(entry, "csl-json"))["type"] == csl_type
    end
  },
  "CSL preserves structured names" => lambda {
    entry = entries_by_id.fetch("publication-spatial-fictions-imagining-trans-national-space-in-the-southern-and-western-peripheries-of")
    authors = JSON.parse(generator.generate(entry, "csl-json"))["author"]
    authors == [
      { "family" => "Wöll", "given" => "Steffen" },
      { "family" => "Pisarz-Ramirez", "given" => "Gabriele" },
      { "family" => "Bozkurt", "given" => "Deniz" }
    ]
  },
  "DOI export avoids duplicate resolver URL" => lambda {
    entry = entries_by_id.fetch("publication-unmasking-maps-unmaking-empire-towards-an-archipelagic-cartography")
    csl = JSON.parse(generator.generate(entry, "csl-json"))
    ris = generator.generate(entry, "ris")
    csl["DOI"] == "10.5070/T814160835" &&
      !csl.key?("URL") &&
      ris.include?("DO  - 10.5070/T814160835") &&
      !ris.include?("UR  - https://doi.org/")
  },
  "CSL forthcoming record omits unknown date" => lambda {
    entry = entries_by_id.fetch("publication-review-of-colonial-ports-global-trade-and-the-roots-of-the-american-revolution-by-jeremy-l")
    csl = JSON.parse(generator.generate(entry, "csl-json"))
    !csl.key?("issued") && csl["status"] == "Forthcoming"
  },
  "CreativeWork export distinguishes poster and manuscript" => lambda {
    poster = entries_by_id.fetch("publication-mapping-discourse-in-r-h-dana-s-two-years-before-the-mast-2")
    manuscript = entries_by_id.fetch("publication-allah-s-own-country-black-nationalism-the-nation-of-islam-and-american-muslim-identities")
    generator.generate(poster, "ris").start_with?("TY  - CONF") &&
      generator.generate(manuscript, "ris").start_with?("TY  - UNPB") &&
      generator.generate(poster, "bibtex").start_with?("@misc{") &&
      generator.generate(manuscript, "bibtex").start_with?("@unpublished{") &&
      JSON.parse(generator.generate(poster, "csl-json"))["type"] == "graphic" &&
      JSON.parse(generator.generate(manuscript, "csl-json"))["type"] == "manuscript"
  },
  "relative file links become canonical URLs" => lambda {
    entry = entries_by_id.fetch("publication-conspicuous-spatializations-visualizing-anti-imperial-spatial-imaginations-of-transhemisph")
    expected_url = "https://steffenwoell.github.io/doc/Conspicuous-Spatializations_Visual-Samples-Steffen-Wöll.pdf"
    generator.generate(entry, "chicago-notes-bibliography").include?(expected_url) &&
      JSON.parse(generator.generate(entry, "csl-json"))["URL"] == expected_url
  },
  "CSL preserves full publication date" => lambda {
    entry = entries_by_id.fetch("publication-the-west-and-the-word-imagining-formatting-and-ordering-the-american-west-in-nineteenth-ce-2")
    JSON.parse(generator.generate(entry, "csl-json")).dig("issued", "date-parts") == [[2021, 1, 28]]
  },
  "map exports creation and update years separately" => lambda {
    entry = entries_by_id.fetch("publication-discursive-map-an-attempt-at-visualizing-the-transnational-trajectories-of-spatial-imagina")
    csl = JSON.parse(generator.generate(entry, "csl-json"))
    csl.dig("issued", "date-parts") == [[2018]] &&
      csl["note"] == "Updated 2022" &&
      generator.generate(entry, "bibtex").include?("note = {Updated 2022}")
  },
  "ongoing website key uses start year" => lambda {
    entry = entries_by_id.fetch("publication-enmma-european-network-for-minor-mobilities-in-the-americas")
    generator.citation_key(entry) == "woell2018enmma"
  },
  "in-progress project remains excluded" => lambda {
    eligible.none? { |entry| entry["id"] == "publication-a-place-between-oceans-imagining-american-empire-1880-1940" }
  },
  "special issue labels and title treatment" => lambda {
    entry = entries_by_id.fetch("publication-archipelagic-spaces-and-im-mobilities")
    chicago = generator.generate(entry, "chicago-notes-bibliography")
    mla_html = generator.generate(entry, "mla-9", format: :html)
    chicago.include?("“Archipelagic Spaces and Im/Mobilities.” Special issue,") &&
      mla_html.include?("<cite>Archipelagic Spaces and Im/Mobilities</cite>. Special issue of <cite>Journal of Transnational American Studies</cite>")
  },
  "Chicago and MLA use style-specific web dates" => lambda {
    entry = entries_by_id.fetch("publication-the-second-cold-war")
    generator.generate(entry, "chicago-notes-bibliography").include?("December 9, 2015") &&
      generator.generate(entry, "mla-9").include?("9 Dec. 2015")
  },
  "poster title uses quotation marks without doubled punctuation" => lambda {
    entry = entries_by_id.fetch("publication-mapping-discourse-in-r-h-dana-s-two-years-before-the-mast-2")
    chicago = generator.generate(entry, "chicago-notes-bibliography")
    chicago.include?("“Mapping Discourse in R.H. Dana’s ‘Two Years Before the Mast’.”") &&
      !chicago.include?(".’.”")
  },
  "unpublished paper title uses quotation marks" => lambda {
    entry = entries_by_id.fetch("publication-allah-s-own-country-black-nationalism-the-nation-of-islam-and-american-muslim-identities")
    %w[chicago-notes-bibliography mla-9].all? do |style|
      generator.generate(entry, style).include?("“Allah’s Own Country:")
    end
  },
  "online review retains exact style-specific date" => lambda {
    entry = entries_by_id.fetch("publication-review-of-the-creole-archipelago-race-and-borders-in-the-colonial-caribbean-by-tessa-murph")
    generator.generate(entry, "chicago-notes-bibliography").include?("September 1, 2023") &&
      generator.generate(entry, "mla-9").include?("1 Sept. 2023")
  },
  "website title treatment differs by style" => lambda {
    entry = entries_by_id.fetch("publication-steffenwoell-github-io")
    chicago = generator.generate(entry, "chicago-notes-bibliography", format: :html)
    mla = generator.generate(entry, "mla-9", format: :html)
    !chicago.include?("<cite>steffenwoell.github.io</cite>") &&
      mla.include?("<cite>steffenwoell.github.io</cite>")
  },
  "short video title treatment differs by style" => lambda {
    entry = entries_by_id.fetch("publication-berkeley-free-speech-rally-riots-united-forces-15-april-2017")
    chicago = generator.generate(entry, "chicago-notes-bibliography", format: :html)
    mla = generator.generate(entry, "mla-9", format: :html)
    chicago.include?("“Berkeley Free Speech Rally Riots") &&
      !chicago.include?("<cite>") &&
      mla.include?("<cite>Berkeley Free Speech Rally Riots")
  },
  "forthcoming prose uses status instead of expected year" => lambda {
    entry = entries_by_id.fetch("publication-ghosts-guides-and-go-betweens-mediating-indigenous-presence-in-alaska-s-imperial-archive")
    %w[chicago-notes-bibliography mla-9].all? do |style|
      output = generator.generate(entry, style)
      output.include?("forthcoming") && !output.include?("2027")
    end
  }
}
quality_cases.each do |label, assertion|
  failures << "quality case failed: #{label}" unless assertion.call
end

abort "Publication citation tests failed:\n\n#{failures.join("\n\n")}" unless failures.empty?

puts "Publication citation tests passed:"
puts "- #{cases.length * styles.length} exact reference outputs"
puts "- #{eligible.length} eligible entries × #{styles.length} formats"
puts "- #{keys.length} unique BibTeX keys"
puts "- complex family-name formatting"
puts "- semantic HTML, fallback status, and deterministic key collisions"
puts "- #{quality_cases.length} bibliographic quality cases"
