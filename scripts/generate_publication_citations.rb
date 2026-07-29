#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "yaml"
require_relative "../lib/publication_citations"

ROOT = File.expand_path("..", __dir__)
OUTPUT_PATH = File.join(ROOT, "_data", "publication-citations-generated.yml")

def load_yaml(name)
  YAML.safe_load(
    File.read(File.join(ROOT, "_data", name)),
    permitted_classes: [Date],
    aliases: false
  )
end

unless ARGV.empty? || ARGV == ["--check"]
  abort "Usage: bundle exec ruby scripts/generate_publication_citations.rb [--check]"
end

publications = load_yaml("publications.yml").fetch("entries")
config = load_yaml("publication-citation.yml")
people = load_yaml("publication-people.yml")
generator = PublicationCitations::Generator.new(people: people, site_url: config["site_url"])
scope = config.fetch("initial_scope")
export_formats = config.fetch("export_formats").to_h { |format| [format.fetch("id"), format] }

eligible = publications.select do |entry|
  scope.fetch("categories").include?(entry["category"]) &&
    scope.fetch("schema_types").include?(entry["schema_type"]) &&
    scope.fetch("statuses").include?(entry["status"])
end
keys = generator.citation_keys(eligible)

generated = eligible.to_h do |entry|
  key = keys.fetch(entry.fetch("id"))
  [
    entry.fetch("id"),
    {
      "title" => entry.fetch("title"),
      "chicago" => {
        "plain" => generator.generate(entry, "chicago-notes-bibliography"),
        "html" => generator.generate(entry, "chicago-notes-bibliography", format: :html)
      },
      "mla" => {
        "plain" => generator.generate(entry, "mla-9"),
        "html" => generator.generate(entry, "mla-9", format: :html)
      },
      "bibtex" => generator.generate(entry, "bibtex", citation_key: key),
      "downloads" => {
        "bibtex" => {
          "filename" => "#{key}.#{export_formats.fetch('bibtex').fetch('extension')}",
          "mime_type" => export_formats.fetch("bibtex").fetch("mime_type"),
          "content" => generator.generate(entry, "bibtex", citation_key: key) + "\n"
        },
        "ris" => {
          "filename" => "#{key}.#{export_formats.fetch('ris').fetch('extension')}",
          "mime_type" => export_formats.fetch("ris").fetch("mime_type"),
          "content" => generator.generate(entry, "ris")
        },
        "csl-json" => {
          "filename" => "#{key}.#{export_formats.fetch('csl-json').fetch('extension')}",
          "mime_type" => export_formats.fetch("csl-json").fetch("mime_type"),
          "content" => generator.generate(entry, "csl-json", citation_key: key)
        }
      }
    }
  ]
end

yaml = YAML.dump(generated)
if ARGV == ["--check"]
  abort "Generated citation data is stale. Run scripts/generate_publication_citations.rb." unless File.exist?(OUTPUT_PATH) && File.read(OUTPUT_PATH) == yaml
  puts "Generated citation data is current: #{generated.length} entries."
else
  File.write(OUTPUT_PATH, yaml)
  puts "Generated #{generated.length} citation records in #{OUTPUT_PATH}."
end
