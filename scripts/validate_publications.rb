#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "set"
require "uri"
require "yaml"

ROOT = File.expand_path("..", __dir__)
DATA_PATH = File.join(ROOT, "_data", "publications.yml")
BASELINE_PATH = File.join(ROOT, "_data", "publications-baseline.yml")
LEGACY_PATH = File.join(ROOT, "publications.md")

ALLOWED_SCHEMA_TYPES = Set.new(%w[
  Article BlogPosting Book Chapter CreativeWork Dataset DigitalDocument
  Review ScholarlyArticle VideoObject WebSite
]).freeze
ALLOWED_STATUSES = Set.new(%w[published in_press forthcoming in_progress]).freeze
ALLOWED_ACCESS = Set.new(%w[open print publisher file web]).freeze
ID_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Date], aliases: false) || {}
rescue Psych::SyntaxError => e
  abort "ERROR: #{path}: #{e.message}"
end

def plain_text(html)
  CGI.unescapeHTML(html.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip)
end

def slug(value)
  value.unicode_normalize(:nfd)
       .gsub(/\p{Mn}/, "")
       .downcase
       .gsub("&", " and ")
       .gsub(/[^a-z0-9]+/, "-")
       .gsub(/\A-+|-+\z/, "")[0, 90]
end

def legacy_inventory(path, categories)
  category_by_label = categories.to_h { |category| [category.fetch("label"), category.fetch("id")] }
  current_category = nil
  used_ids = Hash.new(0)
  entries = []

  File.foreach(path) do |line|
    if (heading = line.match(/^##\s+(.+?)\s*$/))
      current_category = category_by_label[plain_text(heading[1])]
      next
    end

    title_match = line.match(/<p><strong class="hl hl-pub">(.*?)<\/strong>/)
    next unless title_match && current_category

    title = plain_text(title_match[1]).sub(/[.:;]+\z/, "")
    base_id = "publication-#{slug(title)}"
    used_ids[base_id] += 1
    entry_id = used_ids[base_id] == 1 ? base_id : "#{base_id}-#{used_ids[base_id]}"
    entries << { "id" => entry_id, "category" => current_category, "title" => title }
  end

  {
    "schema_version" => 1,
    "source" => "publications.md",
    "total_entries" => entries.length,
    "category_counts" => categories.to_h do |category|
      id = category.fetch("id")
      [id, entries.count { |entry| entry.fetch("category") == id }]
    end,
    "entries" => entries
  }
end

def valid_url?(value)
  return true if value.start_with?("/") && !value.start_with?("//")

  uri = URI.parse(value)
  uri.is_a?(URI::HTTPS) && uri.host && !uri.host.empty?
rescue URI::InvalidURIError
  false
end

def validate_data(data)
  errors = []
  categories = data["categories"]
  entries = data["entries"]

  errors << "schema_version must be 1" unless data["schema_version"] == 1
  errors << "categories must be a non-empty list" unless categories.is_a?(Array) && !categories.empty?
  errors << "entries must be a list" unless entries.is_a?(Array)
  return errors unless categories.is_a?(Array) && entries.is_a?(Array)

  category_ids = categories.filter_map { |category| category["id"] }
  duplicate_categories = category_ids.tally.select { |_id, count| count > 1 }.keys
  errors << "duplicate category IDs: #{duplicate_categories.join(', ')}" unless duplicate_categories.empty?

  categories.each_with_index do |category, index|
    prefix = "categories[#{index}]"
    %w[id label short_label default_schema_type].each do |field|
      errors << "#{prefix}.#{field} is required" if category[field].to_s.strip.empty?
    end
    unless ALLOWED_SCHEMA_TYPES.include?(category["default_schema_type"])
      errors << "#{prefix}.default_schema_type is unsupported: #{category['default_schema_type'].inspect}"
    end
  end

  entry_ids = entries.filter_map { |entry| entry["id"] }
  duplicate_entries = entry_ids.tally.select { |_id, count| count > 1 }.keys
  errors << "duplicate entry IDs: #{duplicate_entries.join(', ')}" unless duplicate_entries.empty?

  entries.each_with_index do |entry, index|
    prefix = "entries[#{index}]"
    %w[id category schema_type title status].each do |field|
      errors << "#{prefix}.#{field} is required" if entry[field].to_s.strip.empty?
    end
    errors << "#{prefix}.id has an invalid format" unless ID_PATTERN.match?(entry["id"].to_s)
    errors << "#{prefix}.category is unknown: #{entry['category'].inspect}" unless category_ids.include?(entry["category"])
    errors << "#{prefix}.schema_type is unsupported: #{entry['schema_type'].inspect}" unless ALLOWED_SCHEMA_TYPES.include?(entry["schema_type"])
    errors << "#{prefix}.status is unsupported: #{entry['status'].inspect}" unless ALLOWED_STATUSES.include?(entry["status"])

    authors = entry["authors"]
    if !authors.is_a?(Array) || authors.empty?
      errors << "#{prefix}.authors must contain at least one person"
    else
      authors.each_with_index do |author, author_index|
        errors << "#{prefix}.authors[#{author_index}].name is required" if author["name"].to_s.strip.empty?
      end
    end

    links = entry["links"]
    if !links.is_a?(Array)
      errors << "#{prefix}.links must be a list"
      next
    end

    links.each_with_index do |link, link_index|
      link_prefix = "#{prefix}.links[#{link_index}]"
      errors << "#{link_prefix}.label is required" if link["label"].to_s.strip.empty?
      errors << "#{link_prefix}.url is invalid" unless valid_url?(link["url"].to_s)
      errors << "#{link_prefix}.access is unsupported: #{link['access'].inspect}" unless ALLOWED_ACCESS.include?(link["access"])
    end
  end

  errors
end

data = load_yaml(DATA_PATH)
errors = validate_data(data)
abort "Publication data validation failed:\n- #{errors.join("\n- ")}" unless errors.empty?

inventory = legacy_inventory(LEGACY_PATH, data.fetch("categories"))

if ARGV == ["--refresh-baseline"]
  File.write(BASELINE_PATH, YAML.dump(inventory))
  puts "Updated #{BASELINE_PATH} with #{inventory.fetch('total_entries')} legacy entries."
  exit
elsif !ARGV.empty?
  abort "Usage: bundle exec ruby scripts/validate_publications.rb [--refresh-baseline]"
end

abort "Missing baseline: run with --refresh-baseline" unless File.exist?(BASELINE_PATH)

baseline = load_yaml(BASELINE_PATH)
unless baseline == inventory
  abort <<~MESSAGE
    Legacy publication inventory differs from _data/publications-baseline.yml.
    Review publications.md, then intentionally refresh the baseline if appropriate:
      bundle exec ruby scripts/validate_publications.rb --refresh-baseline
  MESSAGE
end

puts "Publication data valid: #{data.fetch('entries').length} migrated entries."
puts "Legacy baseline unchanged: #{inventory.fetch('total_entries')} entries across #{inventory.fetch('category_counts').length} categories."
