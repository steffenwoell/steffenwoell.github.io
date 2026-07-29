#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "yaml"

ROOT = File.expand_path("..", __dir__)
PUBLICATIONS_PATH = File.join(ROOT, "_data", "publications.yml")
CONFIG_PATH = File.join(ROOT, "_data", "publication-citation.yml")
CASES_PATH = File.join(ROOT, "_data", "publication-citation-cases.yml")
PEOPLE_PATH = File.join(ROOT, "_data", "publication-people.yml")

def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Date], aliases: false) || {}
rescue Psych::SyntaxError => e
  abort "ERROR: #{path}: #{e.message}"
end

def value_at(entry, path)
  path.split(".").reduce(entry) do |value, key|
    break nil unless value.is_a?(Hash)

    value[key]
  end
end

def present?(value)
  case value
  when Array, Hash
    !value.empty?
  else
    !value.to_s.strip.empty?
  end
end

abort "Usage: bundle exec ruby scripts/audit_publication_citations.rb" unless ARGV.empty?

publications = load_yaml(PUBLICATIONS_PATH)
config = load_yaml(CONFIG_PATH)
cases = load_yaml(CASES_PATH)
people = load_yaml(PEOPLE_PATH)
entries = publications.fetch("entries")
scope = config.fetch("initial_scope")
requirements = config.fetch("requirements")
style_ids = config.fetch("planned_styles").map { |style| style.fetch("id") }

errors = []
warnings = []
eligible = []
excluded = []

entries.each do |entry|
  in_category = scope.fetch("categories").include?(entry["category"])
  in_type = scope.fetch("schema_types").include?(entry["schema_type"])
  next unless in_category

  unless in_type
    excluded << [entry.fetch("id"), "unsupported schema type #{entry['schema_type']}"]
    next
  end
  unless scope.fetch("statuses").include?(entry["status"])
    excluded << [entry.fetch("id"), "status #{entry['status']}"]
    next
  end

  type_requirements = requirements.fetch(entry.fetch("schema_type"))
  missing = type_requirements.fetch("required", []).reject do |path|
    present?(value_at(entry, path))
  end
  required_any = type_requirements.fetch("required_any", [])
  if !required_any.empty? && required_any.none? { |path| present?(value_at(entry, path)) }
    missing << "one of #{required_any.join(', ')}"
  end

  if missing.empty?
    eligible << entry
  else
    errors << "#{entry.fetch('id')}: missing #{missing.join(', ')}"
  end

  Array(entry["authors"])
    .concat(Array(entry["editors"]))
    .concat(Array(entry.dig("book", "editors")))
    .concat(Array(entry.dig("item_reviewed", "authors")))
    .each do |contributor|
      errors << "#{entry.fetch('id')}: missing structured name parts for #{contributor['name']}" unless people.key?(contributor["name"])
    end

  type_requirements.fetch("recommended", []).each do |path|
    warnings << "#{entry.fetch('id')}: missing recommended #{path}" unless present?(value_at(entry, path))
  end
end

case_ids = cases.map { |citation_case| citation_case["id"] }
duplicate_case_ids = case_ids.tally.select { |_id, count| count > 1 }.keys
errors << "duplicate citation case IDs: #{duplicate_case_ids.join(', ')}" unless duplicate_case_ids.empty?

eligible_ids = eligible.map { |entry| entry.fetch("id") }
cases.each_with_index do |citation_case, index|
  prefix = "citation case #{citation_case['id'] || index}"
  publication_id = citation_case["publication_id"]
  errors << "#{prefix}: publication is not eligible in the initial scope" unless eligible_ids.include?(publication_id)

  expected = citation_case["expected"]
  if !expected.is_a?(Hash)
    errors << "#{prefix}: expected must be a mapping"
    next
  end
  missing_styles = style_ids.reject { |style_id| present?(expected[style_id]) }
  errors << "#{prefix}: missing target strings for #{missing_styles.join(', ')}" unless missing_styles.empty?
  unknown_styles = expected.keys - style_ids
  errors << "#{prefix}: unknown target styles #{unknown_styles.join(', ')}" unless unknown_styles.empty?
end

abort "Publication citation audit failed:\n- #{errors.join("\n- ")}" unless errors.empty?

counts = eligible.group_by { |entry| entry.fetch("schema_type") }.transform_values(&:length)
puts "Citation-ready in initial scope: #{eligible.length} entries."
scope.fetch("schema_types").each { |type| puts "- #{type}: #{counts.fetch(type, 0)}" }
puts "Intentionally excluded: #{excluded.length} entries."
excluded.each { |id, reason| puts "- #{id}: #{reason}" }
puts "Reference cases: #{cases.length} entries × #{style_ids.length} target formats."
puts "Recommended metadata gaps: #{warnings.length} (non-blocking)."
warnings.each { |warning| puts "- #{warning}" }
