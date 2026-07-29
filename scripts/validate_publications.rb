#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "set"
require "uri"
require "yaml"

ROOT = File.expand_path("..", __dir__)
DATA_PATH = File.join(ROOT, "_data", "publications.yml")
BASELINE_PATH = File.join(ROOT, "_data", "publications-baseline.yml")

ALLOWED_SCHEMA_TYPES = Set.new(%w[
  Article BlogPosting Book Chapter CreativeWork Dataset DigitalDocument
  Map PublicationIssue Report Review ScholarlyArticle VideoObject WebSite
]).freeze
ALLOWED_STATUSES = Set.new(%w[published in_press forthcoming in_progress ongoing]).freeze
ALLOWED_ACCESS = Set.new(%w[open print publisher file web]).freeze
ALLOWED_LINK_FORMATS = Set.new(%w[pdf]).freeze
ALLOWED_ENTRY_FIELDS = Set.new(%w[
  id category schema_type title authors editors date year status peer_reviewed
  container book pages publisher series doi links note item_reviewed contribution_role
  volume issue date_text title_suffix contributors_position year_format preserve_title_punctuation
  expected_year publisher_year_separator display work_type
  provider date_created date_modified start_year media academic_context citation_key
]).freeze
ALLOWED_CONTRIBUTION_ROLES = Set.new(%w[co_editor]).freeze
ALLOWED_CONTRIBUTOR_POSITIONS = Set.new(%w[after_citation]).freeze
ALLOWED_YEAR_FORMATS = Set.new(%w[plain]).freeze
# Legacy search IDs are truncated at 90 characters and can therefore end in a
# hyphen. They remain valid because changing them would break existing anchors.
ID_PATTERN = /\A[a-z0-9][a-z0-9-]*\z/
DOI_PATTERN = /\A10\.\d{4,9}\/\S+\z/
CITATION_KEY_PATTERN = /\A[a-z][a-z0-9]*\z/

def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Date], aliases: false) || {}
rescue Psych::SyntaxError => e
  abort "ERROR: #{path}: #{e.message}"
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

  featured = data["featured"]
  if featured && !featured.is_a?(Hash)
    errors << "featured must be a mapping"
  elsif featured
    featured_entry_ids = []
    featured.each do |key, config|
      prefix = "featured.#{key}"
      if !config.is_a?(Hash)
        errors << "#{prefix} must be a mapping"
        next
      end

      unknown_fields = config.keys - %w[label entry_id]
      errors << "#{prefix} has unknown fields: #{unknown_fields.join(', ')}" unless unknown_fields.empty?
      errors << "#{prefix}.label is required" if config["label"].to_s.strip.empty?
      entry_id = config["entry_id"].to_s
      errors << "#{prefix}.entry_id is required" if entry_id.strip.empty?
      errors << "#{prefix}.entry_id is unknown: #{entry_id.inspect}" unless entry_ids.include?(entry_id)
      featured_entry_ids << entry_id unless entry_id.empty?
    end
    duplicate_featured = featured_entry_ids.tally.select { |_id, count| count > 1 }.keys
    errors << "duplicate featured entry IDs: #{duplicate_featured.join(', ')}" unless duplicate_featured.empty?
  end

  entries.each_with_index do |entry, index|
    prefix = "entries[#{index}]"
    unknown_fields = entry.keys.reject { |field| ALLOWED_ENTRY_FIELDS.include?(field) }
    errors << "#{prefix} has unknown fields: #{unknown_fields.join(', ')}" unless unknown_fields.empty?
    %w[id category schema_type title status].each do |field|
      errors << "#{prefix}.#{field} is required" if entry[field].to_s.strip.empty?
    end
    errors << "#{prefix}.id has an invalid format" unless ID_PATTERN.match?(entry["id"].to_s)
    errors << "#{prefix}.category is unknown: #{entry['category'].inspect}" unless category_ids.include?(entry["category"])
    errors << "#{prefix}.schema_type is unsupported: #{entry['schema_type'].inspect}" unless ALLOWED_SCHEMA_TYPES.include?(entry["schema_type"])
    errors << "#{prefix}.status is unsupported: #{entry['status'].inspect}" unless ALLOWED_STATUSES.include?(entry["status"])
    if entry.key?("year") && !(entry["year"].is_a?(Integer) && entry["year"].between?(1000, 2999))
      errors << "#{prefix}.year must be a four-digit integer"
    end
    if entry.key?("expected_year") && !(entry["expected_year"].is_a?(Integer) && entry["expected_year"].between?(1000, 2999))
      errors << "#{prefix}.expected_year must be a four-digit integer"
    end
    %w[date_created date_modified start_year].each do |field|
      if entry.key?(field) && !(entry[field].is_a?(Integer) && entry[field].between?(1000, 2999))
        errors << "#{prefix}.#{field} must be a four-digit integer"
      end
    end
    if entry.key?("date") && !entry["date"].is_a?(Date)
      errors << "#{prefix}.date must use YYYY-MM-DD"
    end
    if entry.key?("doi") && !DOI_PATTERN.match?(entry["doi"].to_s)
      errors << "#{prefix}.doi is invalid"
    end
    if entry.key?("citation_key") && !CITATION_KEY_PATTERN.match?(entry["citation_key"].to_s)
      errors << "#{prefix}.citation_key must contain lowercase ASCII letters and numbers"
    end
    if entry.key?("peer_reviewed") && ![true, false].include?(entry["peer_reviewed"])
      errors << "#{prefix}.peer_reviewed must be true or false"
    end

    authors = entry["authors"] || []
    editors = entry["editors"] || []
    if (!authors.is_a?(Array) || authors.empty?) && (!editors.is_a?(Array) || editors.empty?)
      errors << "#{prefix} must contain at least one author or editor"
    elsif authors.is_a?(Array)
      authors.each_with_index do |author, author_index|
        errors << "#{prefix}.authors[#{author_index}].name is required" if author["name"].to_s.strip.empty?
      end
    end
    if editors.is_a?(Array)
      editors.each_with_index do |editor, editor_index|
        errors << "#{prefix}.editors[#{editor_index}].name is required" if editor["name"].to_s.strip.empty?
      end
    end
    if entry.key?("contribution_role") && !ALLOWED_CONTRIBUTION_ROLES.include?(entry["contribution_role"])
      errors << "#{prefix}.contribution_role is unsupported: #{entry['contribution_role'].inspect}"
    end
    if entry.key?("contributors_position") && !ALLOWED_CONTRIBUTOR_POSITIONS.include?(entry["contributors_position"])
      errors << "#{prefix}.contributors_position is unsupported: #{entry['contributors_position'].inspect}"
    end
    if entry.key?("year_format") && !ALLOWED_YEAR_FORMATS.include?(entry["year_format"])
      errors << "#{prefix}.year_format is unsupported: #{entry['year_format'].inspect}"
    end
    if entry.key?("preserve_title_punctuation") && ![true, false].include?(entry["preserve_title_punctuation"])
      errors << "#{prefix}.preserve_title_punctuation must be true or false"
    end
    if entry["schema_type"] == "Review"
      reviewed = entry["item_reviewed"]
      errors << "#{prefix}.item_reviewed.title is required for Review" if !reviewed.is_a?(Hash) || reviewed["title"].to_s.strip.empty?
    end
    if entry.key?("display")
      display = entry["display"]
      if !display.is_a?(Hash)
        errors << "#{prefix}.display must be a mapping"
      else
        unknown_display_fields = display.keys - %w[date detail organization status]
        errors << "#{prefix}.display has unknown fields: #{unknown_display_fields.join(', ')}" unless unknown_display_fields.empty?
        display.each do |field, value|
          errors << "#{prefix}.display.#{field} must be text" unless value.is_a?(String) && !value.strip.empty?
        end
      end
    end
    if entry.key?("media")
      media = entry["media"]
      if !media.is_a?(Hash)
        errors << "#{prefix}.media must be a mapping"
      else
        unknown_media_fields = media.keys - %w[outlet section medium credit year_first]
        errors << "#{prefix}.media has unknown fields: #{unknown_media_fields.join(', ')}" unless unknown_media_fields.empty?
      end
    end
    if entry.key?("academic_context")
      context = entry["academic_context"]
      if !context.is_a?(Hash)
        errors << "#{prefix}.academic_context must be a mapping"
      else
        unknown_context_fields = context.keys - %w[course instructor]
        errors << "#{prefix}.academic_context has unknown fields: #{unknown_context_fields.join(', ')}" unless unknown_context_fields.empty?
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
      if link.key?("format") && !ALLOWED_LINK_FORMATS.include?(link["format"])
        errors << "#{link_prefix}.format is unsupported: #{link['format'].inspect}"
      end
    end
    duplicate_links = links.filter_map { |link| link["url"] }.tally.select { |_url, count| count > 1 }.keys
    errors << "#{prefix} contains duplicate links: #{duplicate_links.join(', ')}" unless duplicate_links.empty?

  end

  errors
end

abort "Usage: bundle exec ruby scripts/validate_publications.rb" unless ARGV.empty?
abort "Missing baseline: #{BASELINE_PATH}" unless File.exist?(BASELINE_PATH)

data = load_yaml(DATA_PATH)
baseline = load_yaml(BASELINE_PATH)
baseline_entries = baseline.fetch("entries")
errors = validate_data(data)
abort "Publication data validation failed:\n- #{errors.join("\n- ")}" unless errors.empty?

publication_ids = data.fetch("entries").map { |entry| entry.fetch("id") }

baseline_ids = baseline_entries.map { |entry| entry.fetch("id") }
duplicate_baseline_ids = baseline_ids.tally.select { |_id, count| count > 1 }.keys
abort "Duplicate baseline IDs: #{duplicate_baseline_ids.join(', ')}" unless duplicate_baseline_ids.empty?

missing_baseline_ids = baseline_ids - publication_ids
unless missing_baseline_ids.empty?
  abort <<~MESSAGE
    Structured publication IDs no longer cover
    _data/publications-baseline.yml:
    - #{missing_baseline_ids.join("\n- ")}
  MESSAGE
end

puts "Publication data valid: #{data.fetch('entries').length} structured entries."
puts "Historical publication baseline retained: #{baseline_entries.length} entries."
