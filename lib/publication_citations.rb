# frozen_string_literal: true

require "cgi"
require "json"

module PublicationCitations
  class Error < StandardError; end

  class Generator
    STOP_WORDS = %w[a an and der die das of on the to towards].freeze

    def initialize(people:, site_url: nil)
      @people = people
      @site_url = site_url.to_s.sub(%r{/\z}, "")
    end

    def generate(entry, style, format: :plain, citation_key: nil)
      text = case style
             when "chicago-notes-bibliography" then chicago(entry)
             when "mla-9" then mla(entry)
             when "bibtex" then bibtex(entry, citation_key: citation_key)
             when "ris" then ris(entry)
             when "csl-json" then csl_json(entry, citation_key: citation_key)
             else raise Error, "Unsupported citation style: #{style}"
             end
      return text if format == :plain
      return html(entry, text, style) if format == :html && style != "bibtex"

      raise Error, "Unsupported citation output format: #{format}"
    end

    def citation_key(entry)
      return entry["citation_key"] if entry["citation_key"]

      contributors = entry["authors"] || entry["editors"]
      author = person(Array(contributors).first).fetch("family")
      family = ascii(author).gsub(/[^a-z0-9]/, "")
      year = publication_year(entry) || entry["status"]
      stable_source = entry.fetch("id").sub(/\Apublication-/, "")
      word = stable_source.scan(/[a-z0-9]+/).find do |candidate|
        !STOP_WORDS.include?(ascii(candidate))
      end
      "#{family}#{year}#{ascii(word)}"
    end

    def citation_keys(entries)
      grouped = entries.group_by { |entry| citation_key(entry) }
      grouped.each_with_object({}) do |(base, matches), result|
        matches.sort_by { |entry| entry.fetch("id") }.each_with_index do |entry, index|
          suffix = matches.length > 1 ? (97 + index).chr : ""
          result[entry.fetch("id")] = "#{base}#{suffix}"
        end
      end
    end

    private

    def chicago(entry)
      case entry.fetch("schema_type")
      when "Book"
        "#{names(entry.fetch('authors'), :bibliography)}. #{entry.fetch('title')}. " \
          "#{entry.dig('publisher', 'name')}, #{year_text(entry)}.#{locator(entry)}"
      when "ScholarlyArticle"
        tail = "#{entry.dig('container', 'title')}"
        tail += " #{entry.dig('container', 'volume')}" if entry.dig("container", "volume")
        tail += ", no. #{entry.dig('container', 'issue')}" if entry.dig("container", "issue")
        tail += " (#{year_text(entry)})"
        tail += ": #{pages(entry)}" if pages(entry)
        "#{names(entry.fetch('authors'), :bibliography)}. “#{quote_title(entry.fetch('title'))}.” " \
          "#{tail}.#{locator(entry)}"
      when "Chapter"
        citation = "#{names(entry.fetch('authors'), :bibliography)}. “#{quote_title(entry.fetch('title'))}.” " \
                   "In #{entry.dig('book', 'title')}"
        editors = entry.dig("book", "editors")
        citation += ", edited by #{names(editors, :display)}" if editors&.any?
        citation += ", #{pages(entry)}" if pages(entry)
        citation += ". #{entry.dig('publisher', 'name')}, #{year_text(entry)}."
        citation + locator(entry)
      when "PublicationIssue"
        citation = "#{names(entry.fetch('editors'), :bibliography)}, ed. "
        if entry.dig("container", "title")
          citation += "“#{quote_title(entry.fetch('title'))}.” Special issue, #{issue_container(entry, :chicago)}"
        else
          citation += "#{entry.fetch('title')} #{entry['volume']} (#{year_text(entry)})."
        end
        citation + locator(entry)
      when "Report"
        citation = "#{names(entry.fetch('authors'), :bibliography)}. #{entry.fetch('title')}."
        citation += " #{entry.dig('series', 'title')}"
        citation += " no. #{entry.dig('series', 'issue')}" if entry.dig("series", "issue")
        citation += ". #{entry.dig('publisher', 'name')}, #{year_text(entry)}."
        citation + locator(entry)
      when "Review"
        review_citation(entry, :chicago)
      when "Dataset", "DigitalDocument", "Map", "CreativeWork", "WebSite", "Article", "BlogPosting", "VideoObject"
        resource_citation(entry, :chicago)
      else
        raise Error, "Unsupported publication type: #{entry['schema_type']}"
      end
    end

    def mla(entry)
      case entry.fetch("schema_type")
      when "Book"
        "#{mla_names(entry.fetch('authors'))}. #{entry.fetch('title')}. " \
          "#{mla_publisher(entry.dig('publisher', 'name'))}, #{year_text(entry)}.#{locator(entry)}"
      when "ScholarlyArticle"
        citation = "#{mla_names(entry.fetch('authors'))}. “#{quote_title(entry.fetch('title'))}.” " \
                   "#{entry.dig('container', 'title')}"
        citation += ", vol. #{entry.dig('container', 'volume')}" if entry.dig("container", "volume")
        citation += ", no. #{entry.dig('container', 'issue')}" if entry.dig("container", "issue")
        citation += ", #{year_text(entry)}"
        citation += ", pp. #{pages(entry)}" if pages(entry)
        citation + "." + locator(entry)
      when "Chapter"
        citation = "#{mla_names(entry.fetch('authors'))}. “#{quote_title(entry.fetch('title'))}.” " \
                   "#{entry.dig('book', 'title')}"
        editors = entry.dig("book", "editors")
        citation += ", edited by #{mla_editor_names(editors)}" if editors&.any?
        citation += ", #{mla_publisher(entry.dig('publisher', 'name'))}, #{year_text(entry)}"
        citation += ", pp. #{pages(entry)}" if pages(entry)
        citation + "." + locator(entry)
      when "PublicationIssue"
        citation = "#{mla_names(entry.fetch('editors'))}, editor. #{entry.fetch('title')}"
        if entry.dig("container", "title")
          citation += ". Special issue of #{entry.dig('container', 'title')}"
          citation += ", vol. #{entry.dig('container', 'volume')}" if entry.dig("container", "volume")
          citation += ", no. #{entry.dig('container', 'issue')}" if entry.dig("container", "issue")
          citation += ", #{year_text(entry)}."
        else
          citation += ", vol. #{entry['volume']}, #{year_text(entry)}."
        end
        citation + locator(entry)
      when "Report"
        citation = "#{mla_names(entry.fetch('authors'))}. #{entry.fetch('title')}."
        citation += " #{entry.dig('series', 'title')}"
        citation += ", no. #{entry.dig('series', 'issue')}" if entry.dig("series", "issue")
        citation += ", #{mla_publisher(entry.dig('publisher', 'name'))}, #{year_text(entry)}."
        citation + locator(entry)
      when "Review"
        review_citation(entry, :mla)
      when "Dataset", "DigitalDocument", "Map", "CreativeWork", "WebSite", "Article", "BlogPosting", "VideoObject"
        resource_citation(entry, :mla)
      else
        raise Error, "Unsupported publication type: #{entry['schema_type']}"
      end
    end

    def bibtex(entry, citation_key: nil)
      type, fields = case entry.fetch("schema_type")
                     when "Book"
                       ["book", {
                         "author" => bibtex_names(entry.fetch("authors")),
                         "title" => entry.fetch("title"),
                         "publisher" => entry.dig("publisher", "name"),
                         "year" => bibtex_year(entry),
                         "note" => bibtex_status(entry),
                         "doi" => entry["doi"]
                       }]
                     when "ScholarlyArticle"
                       ["article", {
                         "author" => bibtex_names(entry.fetch("authors")),
                         "title" => entry.fetch("title"),
                         "journal" => entry.dig("container", "title"),
                         "volume" => entry.dig("container", "volume"),
                         "number" => entry.dig("container", "issue"),
                         "pages" => bibtex_pages(entry),
                         "year" => bibtex_year(entry),
                         "note" => bibtex_status(entry),
                         "doi" => entry["doi"],
                         "url" => entry["doi"] ? nil : best_url(entry)
                       }]
                     when "Chapter"
                       ["incollection", {
                         "author" => bibtex_names(entry.fetch("authors")),
                         "title" => entry.fetch("title"),
                         "booktitle" => entry.dig("book", "title"),
                         "editor" => bibtex_names(entry.dig("book", "editors")),
                         "publisher" => entry.dig("publisher", "name"),
                         "pages" => bibtex_pages(entry),
                         "year" => bibtex_year(entry),
                         "note" => bibtex_status(entry),
                         "doi" => entry["doi"],
                         "url" => entry["doi"] ? nil : best_url(entry)
                       }]
                     when "PublicationIssue"
                       ["misc", {
                         "editor" => bibtex_names(entry.fetch("editors")),
                         "title" => entry.fetch("title"),
                         "howpublished" => issue_container(entry, :bibtex),
                         "year" => bibtex_year(entry),
                         "note" => bibtex_issue_note(entry),
                         "doi" => entry["doi"],
                         "url" => entry["doi"] ? nil : best_url(entry)
                       }]
                     when "Report"
                       ["techreport", {
                         "author" => bibtex_names(entry.fetch("authors")),
                         "title" => entry.fetch("title"),
                         "institution" => entry.dig("publisher", "name"),
                         "type" => entry.dig("series", "title"),
                         "number" => entry.dig("series", "issue"),
                         "year" => bibtex_year(entry),
                         "doi" => entry["doi"],
                         "url" => entry["doi"] ? nil : best_url(entry)
                       }]
                     when "Review"
                       ["article", {
                         "author" => bibtex_names(entry.fetch("authors")),
                         "title" => entry.fetch("title"),
                         "journal" => entry.dig("container", "title"),
                         "volume" => entry.dig("container", "volume"),
                         "number" => entry.dig("container", "issue"),
                         "pages" => bibtex_pages(entry),
                         "year" => bibtex_year(entry),
                         "note" => bibtex_status(entry),
                         "doi" => entry["doi"],
                         "url" => entry["doi"] ? nil : best_url(entry)
                       }]
                     when "Dataset", "DigitalDocument", "Map", "CreativeWork", "WebSite", "Article", "BlogPosting", "VideoObject"
                       resource_bibtex(entry)
                     else
                       raise Error, "Unsupported publication type: #{entry['schema_type']}"
                     end

      populated = fields.compact.reject { |_key, value| value.to_s.empty? }
      lines = populated.map.with_index do |(field, value), index|
        comma = index == populated.length - 1 ? "" : ","
        escaped = bibtex_escape(value)
        escaped = "{#{escaped}}" if %w[title booktitle].include?(field)
        "  #{field} = {#{escaped}}#{comma}"
      end
      "@#{type}{#{citation_key || self.citation_key(entry)},\n#{lines.join("\n")}\n}"
    end

    def ris(entry)
      lines = [["TY", ris_type(entry)]]
      ris_people(lines, "AU", entry["authors"])
      ris_people(lines, "ED", entry["editors"] || entry.dig("book", "editors"))
      lines << ["T1", entry.fetch("title")]

      container = entry.dig("container", "title") || media_outlet(entry)
      book = entry.dig("book", "title")
      lines << ["T2", book] if book
      lines << ["JO", container] if container
      lines << ["VL", entry.dig("container", "volume") || entry["volume"]]
      lines << ["IS", entry.dig("container", "issue")]
      lines << ["SP", entry.dig("pages", "start")]
      lines << ["EP", entry.dig("pages", "end")]
      lines << ["PY", publication_year(entry)]
      lines << ["DA", entry["date"]&.strftime("%Y/%m/%d")]
      lines << ["PB", entry.dig("publisher", "name") || entry.dig("provider", "name")]
      lines << ["T3", entry.dig("series", "title")]
      lines << ["M1", entry.dig("series", "issue")]
      lines << ["C3", entry.dig("display", "organization")]
      lines << ["DO", entry["doi"]]
      lines << ["UR", export_url(entry)]
      lines << ["N1", export_note(entry)]
      lines << ["ER", nil]

      lines.filter_map do |tag, value|
        next if tag != "ER" && value.to_s.empty?

        "#{tag}  - #{ris_value(value)}"
      end.join("\r\n") + "\r\n"
    end

    def csl_json(entry, citation_key: nil)
      data = {
        "id" => citation_key || self.citation_key(entry),
        "type" => csl_type(entry),
        "title" => entry.fetch("title"),
        "author" => csl_people(entry["authors"]),
        "editor" => csl_people(entry["editors"] || entry.dig("book", "editors")),
        "container-title" => entry.dig("container", "title") || entry.dig("book", "title") || media_outlet(entry),
        "reviewed-title" => entry.dig("item_reviewed", "title"),
        "reviewed-author" => csl_people(entry.dig("item_reviewed", "authors")),
        "volume" => entry.dig("container", "volume") || entry["volume"],
        "issue" => entry.dig("container", "issue"),
        "page" => pages(entry),
        "publisher" => entry.dig("publisher", "name") || entry.dig("provider", "name"),
        "collection-title" => entry.dig("series", "title"),
        "collection-number" => entry.dig("series", "issue"),
        "issued" => csl_date(entry),
        "DOI" => entry["doi"],
        "URL" => export_url(entry),
        "status" => export_status(entry),
        "genre" => resource_genre(entry),
        "event" => entry.dig("display", "organization"),
        "note" => export_note(entry)
      }.compact.reject { |_key, value| value.respond_to?(:empty?) && value.empty? }
      JSON.pretty_generate(data) + "\n"
    end

    def person(value)
      name = value.fetch("name")
      @people.fetch(name) { raise Error, "Missing structured name parts for #{name}" }
    end

    def names(values, mode)
      people = Array(values).map { |value| person(value) }
      return "" if people.empty?

      rendered = people.map.with_index do |item, index|
        if mode == :bibliography && index.zero?
          "#{item.fetch('family')}, #{item.fetch('given')}"
        else
          "#{item.fetch('given')} #{item.fetch('family')}"
        end
      end
      return "#{rendered.first}, and #{rendered.last}" if mode == :bibliography && rendered.length == 2

      join_names(rendered)
    end

    def mla_names(values)
      people = Array(values).map { |value| person(value) }
      first = people.first
      lead = "#{first.fetch('family')}, #{first.fetch('given')}"
      return lead if people.length == 1
      return "#{lead}, and #{people.last.fetch('given')} #{people.last.fetch('family')}" if people.length == 2

      "#{lead}, et al"
    end

    def mla_editor_names(values)
      people = Array(values).map { |value| person(value) }
      first = "#{people.first.fetch('given')} #{people.first.fetch('family')}"
      return first if people.length == 1
      return "#{first} and #{people.last.fetch('given')} #{people.last.fetch('family')}" if people.length == 2

      "#{first} et al."
    end

    def mla_publisher(name)
      publisher = name.to_s
      publisher = publisher.sub(/\AUniversity of (.+) Press\z/, 'U of \1 P')
      publisher = publisher.sub(/ University Press\z/, " UP")
      publisher.gsub(/\s+(?:&|\+)\s+/, " and ")
    end

    def join_names(values)
      return values.first if values.length == 1
      return values.join(" and ") if values.length == 2

      "#{values[0...-1].join(', ')}, and #{values.last}"
    end

    def bibtex_names(values)
      Array(values).map do |value|
        item = person(value)
        "#{item.fetch('family')}, #{item.fetch('given')}"
      end.join(" and ")
    end

    def ris_type(entry)
      {
        "Book" => "BOOK",
        "PublicationIssue" => "SER",
        "ScholarlyArticle" => "JOUR",
        "Chapter" => "CHAP",
        "Report" => "RPRT",
        "Review" => "JOUR",
        "Dataset" => "DATA",
        "DigitalDocument" => "ELEC",
        "Map" => "MAP",
        "CreativeWork" => entry["category"] == "early-work" ? "UNPB" : "CONF",
        "WebSite" => "ELEC",
        "Article" => "JOUR",
        "BlogPosting" => "BLOG",
        "VideoObject" => "VIDEO"
      }.fetch(entry.fetch("schema_type"))
    end

    def csl_type(entry)
      {
        "Book" => "book",
        "PublicationIssue" => "periodical",
        "ScholarlyArticle" => "article-journal",
        "Chapter" => "chapter",
        "Report" => "report",
        "Review" => "review",
        "Dataset" => "dataset",
        "DigitalDocument" => "document",
        "Map" => "map",
        "CreativeWork" => entry["category"] == "early-work" ? "manuscript" : "graphic",
        "WebSite" => "webpage",
        "Article" => "article",
        "BlogPosting" => "post-weblog",
        "VideoObject" => "motion_picture"
      }.fetch(entry.fetch("schema_type"))
    end

    def ris_people(lines, tag, values)
      Array(values).each do |value|
        item = person(value)
        lines << [tag, "#{item.fetch('family')}, #{item.fetch('given')}"]
      end
    end

    def csl_people(values)
      people = Array(values).map do |value|
        item = person(value)
        { "family" => item.fetch("family"), "given" => item.fetch("given") }
      end
      people.empty? ? nil : people
    end

    def csl_date(entry)
      date = entry["date"]
      if date.respond_to?(:year) && date.respond_to?(:month) && date.respond_to?(:day)
        return { "date-parts" => [[date.year, date.month, date.day]] }
      end

      year = publication_year(entry)
      year ? { "date-parts" => [[year]] } : nil
    end

    def export_status(entry)
      return "Forthcoming" if entry["status"] == "forthcoming"
      return "In press" if entry["status"] == "in_press"
      return "Ongoing" if entry["status"] == "ongoing"
    end

    def export_note(entry)
      notes = [export_status(entry)]
      notes << "Updated #{entry['date_modified']}" if entry["date_modified"]
      notes << resource_bibtex_note(entry) if entry["schema_type"] == "CreativeWork"
      value = notes.compact.reject(&:empty?).join(". ")
      value.empty? ? nil : value
    end

    def resource_genre(entry)
      return entry["work_type"] if entry["schema_type"] == "CreativeWork"
      return entry.dig("media", "medium") if entry["schema_type"] == "VideoObject"
      return "Digital document" if entry["schema_type"] == "DigitalDocument"
      return "Map" if entry["schema_type"] == "Map"
      return "Dataset" if entry["schema_type"] == "Dataset"
    end

    def ris_value(value)
      value.to_s.gsub(/[\r\n]+/, " ").strip
    end

    def year_text(entry)
      year = publication_year(entry)
      return year.to_s if entry["status"] == "published"
      return "forthcoming" if %w[forthcoming in_press].include?(entry["status"])

      year.to_s
    end

    def issue_container(entry, style)
      title = entry.dig("container", "title")
      return unless title

      volume = entry.dig("container", "volume")
      issue = entry.dig("container", "issue")
      case style
      when :chicago
        output = title.to_s
        output += " #{volume}" if volume
        output += ", no. #{issue}" if issue
        output + " (#{year_text(entry)})."
      when :mla
        output = title.to_s
        output += ", vol. #{volume}" if volume
        output += ", no. #{issue}" if issue
        output + ", #{year_text(entry)}."
      when :bibtex
        output = title.to_s
        output += " #{volume}" if volume
        output += ", no. #{issue}" if issue
        output
      end
    end

    def review_citation(entry, style)
      reviewed = entry.fetch("item_reviewed")
      reviewed_authors = style == :mla ? mla_editor_names(reviewed.fetch("authors")) : names(reviewed.fetch("authors"), :display)
      lead = style == :mla ? mla_names(entry.fetch("authors")) : names(entry.fetch("authors"), :bibliography)
      citation = "#{lead}. Review of #{reviewed.fetch('title')}, by #{reviewed_authors}. "
      citation += entry.dig("container", "title").to_s
      volume = entry.dig("container", "volume")
      issue = entry.dig("container", "issue")
      year = publication_year(entry)
      date = style_date(entry, style)

      if style == :mla
        citation += ", vol. #{volume}" if volume
        citation += ", no. #{issue}" if issue
        citation += ", #{volume ? year : date}" if year || date
        citation += ", pp. #{pages(entry)}" if pages(entry)
        citation += "."
      else
        citation += " #{volume}" if volume
        citation += ", no. #{issue}" if issue
        citation += volume ? " (#{year})" : ", #{date}" if year || date
        citation += ": #{pages(entry)}" if pages(entry)
        citation += "."
      end
      citation += " Forthcoming." if entry["status"] == "forthcoming" && !year
      citation + locator(entry)
    end

    def resource_citation(entry, style)
      lead = style == :mla ? mla_names(entry.fetch("authors")) : names(entry.fetch("authors"), :bibliography)
      type = entry.fetch("schema_type")
      quoted = %w[Article BlogPosting CreativeWork].include?(type) ||
               (type == "VideoObject" && style == :chicago)
      raw_title = entry.fetch("title")
      title = if quoted
                "“#{quote_title(raw_title)}.”"
              else
                raw_title.match?(/[.!?](?:[”’"'])?\z/) ? raw_title : "#{raw_title}."
              end
      details = resource_details(entry, style)
      citation = "#{lead}. #{title}"
      citation += " #{details.join(', ')}." unless details.empty?
      citation + locator(entry)
    end

    def resource_details(entry, style)
      type = entry.fetch("schema_type")
      date = style_date(entry, style)
      case type
      when "Dataset"
        if style == :mla
          [entry.dig("provider", "name"), date, "Dataset"].compact
        else
          ["Dataset", entry.dig("provider", "name"), date].compact
        end
      when "DigitalDocument"
        ["Digital document", date].compact
      when "Map"
        details = ["Map", entry["date_created"]]
        details << "updated #{entry['date_modified']}" if entry["date_modified"]
        details.compact
      when "CreativeWork"
        details = [entry["work_type"]]
        if entry["category"] == "posters"
          details << entry.dig("display", "organization")
        elsif entry["category"] == "early-work"
          details << entry.dig("academic_context", "course")
        end
        details << date
        details.compact
      when "WebSite"
        value = entry.dig("display", "date") || date
        style == :mla ? [value].compact : ["Website", value].compact
      when "Article"
        [media_outlet(entry), date].compact
      when "BlogPosting"
        [entry.dig("media", "outlet"), entry.dig("media", "section"), date].compact
      when "VideoObject"
        [entry.dig("media", "medium") || "Video", date].compact
      end
    end

    def resource_bibtex(entry)
      common = {
        "author" => bibtex_names(entry.fetch("authors")),
        "title" => entry.fetch("title"),
        "year" => bibtex_year(entry),
        "doi" => entry["doi"],
        "url" => entry["doi"] ? nil : best_url(entry)
      }
      case entry.fetch("schema_type")
      when "Dataset"
        ["misc", common.merge(
          "howpublished" => ["Dataset", entry.dig("provider", "name")].compact.join(", ")
        )]
      when "DigitalDocument"
        ["misc", common.merge("howpublished" => "Digital document")]
      when "Map"
        ["misc", common.merge(
          "howpublished" => "Map",
          "note" => entry["date_modified"] ? "Updated #{entry['date_modified']}" : nil
        )]
      when "CreativeWork"
        type = entry["category"] == "early-work" ? "unpublished" : "misc"
        ["#{type}", common.merge("note" => resource_bibtex_note(entry))]
      when "WebSite"
        ["misc", common.merge("howpublished" => "Website", "note" => "Ongoing")]
      when "Article"
        ["article", common.merge("journal" => media_outlet(entry))]
      when "BlogPosting"
        ["misc", common.merge(
          "howpublished" => [entry.dig("media", "outlet"), entry.dig("media", "section")].compact.join(", ")
        )]
      when "VideoObject"
        ["misc", common.merge("howpublished" => entry.dig("media", "medium") || "Video")]
      end
    end

    def resource_bibtex_note(entry)
      parts = [entry["work_type"]]
      if entry["category"] == "posters"
        parts << entry.dig("display", "organization")
      elsif entry["category"] == "early-work"
        parts << entry.dig("academic_context", "course")
      end
      parts.compact.join(", ")
    end

    def media_outlet(entry)
      entry.dig("media", "outlet") || entry.dig("media", "credit")&.sub(/\AFor\s+/i, "")
    end

    def style_date(entry, style)
      date = entry["date"]
      return entry.dig("display", "date") || publication_year(entry)&.to_s unless date.respond_to?(:year)

      if style == :chicago
        "#{date.strftime('%B')} #{date.day}, #{date.year}"
      else
        months = %w[Jan. Feb. Mar. Apr. May June July Aug. Sept. Oct. Nov. Dec.]
        "#{date.day} #{months.fetch(date.month - 1)} #{date.year}"
      end
    end

    def publication_year(entry)
      entry["year"] || entry["expected_year"] || entry["start_year"] || entry["date_created"]
    end

    def bibtex_year(entry)
      publication_year(entry).to_s
    end

    def bibtex_issue_note(entry)
      return bibtex_status(entry) if bibtex_status(entry)
      return "Volume #{entry['volume']}" if entry["volume"]
    end

    def bibtex_status(entry)
      return "Forthcoming" if entry["status"] == "forthcoming"
      return "In press" if entry["status"] == "in_press"
    end

    def pages(entry)
      start_page = entry.dig("pages", "start")
      return unless start_page

      end_page = entry.dig("pages", "end")
      end_page ? "#{start_page}–#{end_page}" : start_page.to_s
    end

    def bibtex_pages(entry)
      pages(entry)&.gsub("–", "--")
    end

    def quote_title(title)
      title.tr("“”", "‘’").sub(/\.(?=’?\z)/, "")
    end

    def locator(entry)
      value = entry["doi"] ? "https://doi.org/#{entry['doi']}" : best_url(entry)
      value ? " #{value}." : ""
    end

    def best_url(entry)
      link = entry.fetch("links", []).find do |candidate|
        url = candidate["url"].to_s
        url.start_with?("https://") || url.start_with?("/")
      end
      link && absolute_url(link["url"])
    end

    def export_url(entry)
      doi_url = entry["doi"] && "https://doi.org/#{entry['doi']}"
      link = entry.fetch("links", []).find do |candidate|
        url = absolute_url(candidate["url"])
        url&.start_with?("https://") && url != doi_url
      end
      link && absolute_url(link["url"])
    end

    def absolute_url(value)
      url = value.to_s
      return url if url.start_with?("https://")
      return "#{@site_url}#{url}" if url.start_with?("/") && !@site_url.empty?
    end

    def bibtex_escape(value)
      value.to_s
           .gsub("\\", "\\\\")
           .gsub(/([%&_#])/, '\\\\\1')
           .gsub("{", "\\{")
           .gsub("}", "\\}")
    end

    def html(entry, text, style)
      escaped = CGI.escapeHTML(text)
      emphasized = case entry.fetch("schema_type")
                   when "Book" then [entry.fetch("title")]
                   when "ScholarlyArticle" then [entry.dig("container", "title")]
                   when "Chapter" then [entry.dig("book", "title")]
                   when "PublicationIssue"
                     if entry.dig("container", "title")
                       style == "mla-9" ? [entry.fetch("title"), entry.dig("container", "title")] : [entry.dig("container", "title")]
                     else
                       [entry.fetch("title")]
                     end
                   when "Report" then [entry.fetch("title")]
                   when "Review" then [entry.dig("item_reviewed", "title"), entry.dig("container", "title")]
                   when "Article", "BlogPosting" then [media_outlet(entry)]
                   when "Dataset", "DigitalDocument", "Map" then [entry.fetch("title")]
                   when "WebSite" then style == "mla-9" ? [entry.fetch("title")] : []
                   when "VideoObject" then style == "mla-9" ? [entry.fetch("title")] : []
                   else []
                   end
      emphasized.compact.uniq.reduce(escaped) do |output, value|
        escaped_value = CGI.escapeHTML(value)
        output.sub(escaped_value, "<cite>#{escaped_value}</cite>")
      end
    end

    def ascii(value)
      transliterated = {
        "Ä" => "Ae", "Ö" => "Oe", "Ü" => "Ue",
        "ä" => "ae", "ö" => "oe", "ü" => "ue", "ß" => "ss"
      }.reduce(value.to_s) { |text, (character, replacement)| text.gsub(character, replacement) }
      transliterated
           .unicode_normalize(:nfkd)
           .encode("ASCII", invalid: :replace, undef: :replace, replace: "")
           .downcase
    end
  end
end
