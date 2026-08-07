#!/bin/zsh

set -u
set -o pipefail

SCRIPT_DIR=${0:A:h}
SITE_DIR=${SCRIPT_DIR:h}
PROJECTS_FILE="$SITE_DIR/_data/projects.yml"
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: scripts/update-project-versions.zsh [--dry-run]

Update project versions and, when explicitly present in a release heading,
codenames in _data/projects.yml from each project's latest GitHub release.

Options:
  --dry-run  Show the resulting changes without modifying the YAML file.
  -h, --help Show this help text.

Set GITHUB_TOKEN to a GitHub token if authenticated API requests are desired.
EOF
}

while (( $# > 0 )); do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      print -u2 "Unknown option: $1"
      usage >&2
      exit 2
      ;;
  esac
  shift
done

for command_name in curl ruby; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    print -u2 "Required command not found: $command_name"
    exit 1
  fi
done

if [[ ! -f "$PROJECTS_FILE" ]]; then
  print -u2 "Project data not found: $PROJECTS_FILE"
  exit 1
fi

TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/project-releases.XXXXXX") || exit 1
cleanup() {
  rm -rf -- "$TEMP_DIR"
}
trap cleanup EXIT HUP INT TERM

PROJECT_LIST="$TEMP_DIR/projects.tsv"
if ! ruby -ryaml -e '
  path = ARGV.fetch(0)
  projects = YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
  abort "Expected a project list in #{path}" unless projects.is_a?(Array)

  projects.each_with_index do |project, index|
    title = project["title"].to_s
    url = project["url"].to_s
    match = url.match(%r{\Ahttps://github\.com/([^/]+)/([^/#]+?)/?\z}i)
    abort "Invalid GitHub project URL for #{title.inspect}: #{url.inspect}" unless match
    puts [index, title, match[1], match[2]].join("\t")
  end
' "$PROJECTS_FILE" > "$PROJECT_LIST"; then
  print -u2 "Could not read project data. No changes were made."
  exit 1
fi

curl_headers=(
  -H "Accept: application/vnd.github+json"
  -H "X-GitHub-Api-Version: 2022-11-28"
  -H "User-Agent: steffenwoell.github.io-project-updater"
)

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  curl_headers+=( -H "Authorization: Bearer $GITHUB_TOKEN" )
fi

fetch_failed=0
while IFS=$'\t' read -r project_index project_title project_owner project_repo; do
  release_file="$TEMP_DIR/release-$project_index.json"
  release_url="https://api.github.com/repos/$project_owner/$project_repo/releases/latest"

  print "Checking $project_title …"
  if ! curl --fail --silent --show-error --location \
      --connect-timeout 10 --max-time 30 --retry 2 --retry-delay 1 \
      "${curl_headers[@]}" \
      --output "$release_file" \
      "$release_url"; then
    print -u2 "Could not retrieve the latest release for $project_title."
    fetch_failed=1
  fi
done < "$PROJECT_LIST"

if (( fetch_failed )); then
  print -u2 "At least one release request failed. No changes were made."
  exit 1
fi

UPDATED_FILE="$TEMP_DIR/projects.yml"
if ! ruby -rjson -ryaml -e '
  source_path, project_list_path, release_dir, destination_path = ARGV
  source = File.read(source_path)
  projects = YAML.safe_load(source, permitted_classes: [], aliases: false)

  File.foreach(project_list_path) do |line|
    index_text, title, = line.chomp.split("\t", 4)
    index = Integer(index_text, 10)
    project = projects.fetch(index)
    release = JSON.parse(File.read(File.join(release_dir, "release-#{index}.json")))

    tag = release["tag_name"].to_s.strip
    version = tag.sub(/\Av/i, "")
    unless version.match?(/\A[0-9][0-9A-Za-z._+-]*\z/)
      abort "Unexpected release tag for #{title}: #{tag.inspect}"
    end

    heading = release["body"].to_s.lines.find { |entry| entry.match?(/\A\s*#+\s+/) }.to_s
    codename_match = heading.match(/[\"“]([^\"”\r\n]+)[\"”]/)
    codename = codename_match && codename_match[1].strip
    codename = nil unless codename&.match?(/\A[[:alnum:]][[:alnum:] ._+-]*\z/)

    title_pattern = Regexp.escape(project.fetch("title").to_s)
    block_pattern = /(^- title:\s*#{title_pattern}\s*$.*?)(?=^- title:|\z)/m
    block_match = source.match(block_pattern)
    abort "Could not locate YAML block for #{title.inspect}" unless block_match

    updated_block = block_match[1].sub(/^(\s*version:)\s*.*$/, "\\1 #{version}")
    if codename
      if updated_block.match?(/^\s*codename:/)
        updated_block = updated_block.sub(/^(\s*codename:)\s*.*$/, "\\1 #{codename}")
      else
        updated_block = updated_block.sub(/^(\s*version:\s*.*)$/) { "#{$1}\n  codename: #{codename}" }
      end
    end

    source = source.sub(block_pattern) { updated_block }
  end

  File.write(destination_path, source)
' "$PROJECTS_FILE" "$PROJECT_LIST" "$TEMP_DIR" "$UPDATED_FILE"; then
  print -u2 "Release data could not be processed. No changes were made."
  exit 1
fi

if cmp -s "$PROJECTS_FILE" "$UPDATED_FILE"; then
  print "Project versions are already up to date."
  exit 0
fi

if (( DRY_RUN )); then
  diff -u "$PROJECTS_FILE" "$UPDATED_FILE" || true
  print "Dry run complete. No changes were made."
  exit 0
fi

PROJECTS_TMP="$SITE_DIR/_data/.projects.yml.tmp.$$"
cp "$PROJECTS_FILE" "$TEMP_DIR/projects-before.yml" || exit 1
cp "$UPDATED_FILE" "$PROJECTS_TMP" || exit 1
mv "$PROJECTS_TMP" "$PROJECTS_FILE" || exit 1

print "Updated _data/projects.yml:"
diff -u "$TEMP_DIR/projects-before.yml" "$PROJECTS_FILE" 2>/dev/null || true
ruby -ryaml -e '
  YAML.safe_load(File.read(ARGV.fetch(0)), permitted_classes: [], aliases: false).each do |project|
    puts "  #{project["title"]}: v#{project["version"]} · #{project["codename"]}"
  end
' "$PROJECTS_FILE"
