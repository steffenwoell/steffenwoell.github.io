#!/bin/zsh

# Crawl a website and check every discovered HTTP(S) link.
# Requires: zsh, curl, Ruby (standard library only).

emulate -L zsh
setopt errexit nounset pipefail extended_glob

readonly DEFAULT_URL="https://steffenwoell.github.io/"

site_url="$DEFAULT_URL"
jobs=8
timeout=20
report_file=""
external_only=0

usage() {
  cat <<'EOF'
Usage: scripts/check-site-links.zsh [options]

Options:
  -u, --url URL       Website to crawl (default: https://steffenwoell.github.io/)
  -j, --jobs NUMBER   Parallel link checks (default: 8)
  -t, --timeout SEC   Timeout per request (default: 20)
  -o, --report FILE   Also save a tab-separated report
      --external-only Check only external links after crawling the site
  -h, --help          Show this help

Examples:
  scripts/check-site-links.zsh
  scripts/check-site-links.zsh --url http://localhost:4000/
  scripts/check-site-links.zsh --external-only --report link-report.tsv
EOF
}

die() {
  print -u2 -- "Error: $*"
  exit 2
}

while (( $# > 0 )); do
  case "$1" in
    -u|--url)
      (( $# >= 2 )) || die "$1 requires a URL"
      site_url="$2"
      shift 2
      ;;
    -j|--jobs)
      (( $# >= 2 )) || die "$1 requires a number"
      jobs="$2"
      shift 2
      ;;
    -t|--timeout)
      (( $# >= 2 )) || die "$1 requires a number"
      timeout="$2"
      shift 2
      ;;
    -o|--report)
      (( $# >= 2 )) || die "$1 requires a file path"
      report_file="$2"
      shift 2
      ;;
    --external-only)
      external_only=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

[[ "$jobs" == <-> && "$jobs" -gt 0 ]] || die "jobs must be a positive integer"
[[ "$timeout" == <-> && "$timeout" -gt 0 ]] || die "timeout must be a positive integer"
[[ "$site_url" == http://* || "$site_url" == https://* ]] || die "URL must begin with http:// or https://"

# URI.join also normalizes the base URL and supplies a trailing slash where needed.
site_url="$(ruby -ruri -e 'u = URI(ARGV.fetch(0)); u.path = "/" if u.path.empty?; puts u' "$site_url")"
readonly base_host="${${site_url#*://}%%/*}"

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/site-link-check.XXXXXX")"
trap 'rm -rf -- "$tmp_dir"' EXIT HUP INT TERM

typeset -A visited_pages queued_pages discovered source_page
typeset -a page_queue crawl_failures

page_queue=("$site_url")
queued_pages[$site_url]=1

is_internal_url() {
  local url="$1"
  local host="${${url#*://}%%/*}"
  [[ "${host:l}" == "${base_host:l}" ]]
}

is_probable_html() {
  local path="${${1%%\?*}:l}"
  [[ "$path" != *.(asc|avif|bib|css|csv|doc|docx|eot|gif|ico|ics|jpeg|jpg|js|json|map|mp3|mp4|odt|pdf|png|ppt|pptx|ris|svg|tif|tiff|tsv|txt|webm|webp|woff|woff2|xml|zip) ]]
}

print -- "Crawling $site_url"

while (( ${#page_queue[@]} > 0 )); do
  page_url="${page_queue[1]}"
  page_queue[1]=()

  [[ -n "${visited_pages[$page_url]-}" ]] && continue
  visited_pages[$page_url]=1

  page_file="$tmp_dir/page-${#visited_pages}.html"
  if ! curl --location --silent --show-error --fail \
      --max-time "$timeout" \
      --user-agent "SteffenWoellLinkChecker/1.0 (+${site_url})" \
      --output "$page_file" \
      "$page_url" 2>"$tmp_dir/crawl-error"; then
    crawl_error="$(<"$tmp_dir/crawl-error")"
    crawl_failures+=("$page_url	$crawl_error")
    print -u2 -- "  Could not crawl: $page_url"
    continue
  fi

  print -- "  ${#visited_pages}: $page_url"

  # Extract href attributes, decode HTML entities, and resolve relative URLs.
  ruby -ruri -rcgi -e '
    base = ARGV.fetch(0)
    html = STDIN.read
    hrefs = html.scan(/<a\b[^>]*?\bhref\s*=\s*(?:(["'"'"'])(.*?)\1|([^\s>]+))/im)
    hrefs.each do |_quote, quoted, bare|
      href = CGI.unescapeHTML(quoted || bare || "").strip
      next if href.empty? || href.start_with?("#")
      next if href.match?(/\A(?:mailto|tel|javascript|data):/i)
      href = href.split("#", 2).first
      begin
        uri = URI.join(base, href)
        puts uri if %w[http https].include?(uri.scheme&.downcase)
      rescue URI::InvalidURIError
        warn "Invalid URL on #{base}: #{href}"
      end
    end
  ' "$page_url" < "$page_file" | while IFS= read -r found_url; do
    # HTTP checks do not send fragments to the server.
    check_url="${found_url%%\#*}"
    [[ -n "$check_url" ]] || continue

    if [[ -z "${discovered[$check_url]-}" ]]; then
      discovered[$check_url]=1
      source_page[$check_url]="$page_url"
    fi

    if is_internal_url "$check_url" && is_probable_html "$check_url"; then
      crawl_url="${check_url%%\?*}"
      if [[ -z "${visited_pages[$crawl_url]-}" && -z "${queued_pages[$crawl_url]-}" ]]; then
        page_queue+=("$crawl_url")
        queued_pages[$crawl_url]=1
      fi
    fi
  done
done

url_list="$tmp_dir/urls.tsv"
: > "$url_list"
for url in ${(k)discovered}; do
  if (( external_only )) && is_internal_url "$url"; then
    continue
  fi
  print -r -- "$url	${source_page[$url]}" >> "$url_list"
done

sort -o "$url_list" "$url_list"
link_count="$(wc -l < "$url_list" | tr -d ' ')"
print -- "\nChecking $link_count unique links with $jobs parallel requests …"

worker="$tmp_dir/check-one.zsh"
cat > "$worker" <<'WORKER'
#!/bin/zsh
emulate -L zsh
setopt nounset pipefail

timeout="$1"
site_url="$2"
line="$3"
url="${line%%$'\t'*}"
source="${line#*$'\t'}"
user_agent="SteffenWoellLinkChecker/1.0 (+${site_url})"

request() {
  local method="$1"
  local -a args
  args=(--location --silent --show-error --max-time "$timeout" --retry 1
        --retry-delay 1 --user-agent "$user_agent" --output /dev/null
        --write-out $'%{http_code}\t%{url_effective}')
  [[ "$method" == HEAD ]] && args+=(--head)
  [[ "$method" == RANGE ]] && args+=(--range 0-65535)
  curl "${args[@]}" "$url" 2>/dev/null
}

response="$(request HEAD)"
http_code="${response%%$'\t'*}"

# Some sites reject HEAD requests although a normal browser request succeeds.
if [[ "$http_code" == 000 || "$http_code" == 403 || "$http_code" == 405 ]]; then
  response="$(request RANGE)"
  http_code="${response%%$'\t'*}"
fi

effective="${response#*$'\t'}"
case "$http_code" in
  2??|3??) result="OK" ;;
  401|403|429) result="WARN" ;;
  *) result="BROKEN" ;;
esac

print -r -- "$result"$'\t'"$http_code"$'\t'"$url"$'\t'"$effective"$'\t'"$source"
WORKER
chmod 700 "$worker"

results_file="$tmp_dir/results.tsv"
if (( link_count > 0 )); then
  # NUL separation keeps URLs intact even when they contain spaces or quotes.
  tr '\n' '\0' < "$url_list" | \
    xargs -0 -P "$jobs" -n 1 "$worker" "$timeout" "$site_url" > "$results_file"
else
  : > "$results_file"
fi

sort -o "$results_file" "$results_file"

ok_count="$(awk -F '\t' '$1 == "OK" {n++} END {print n+0}' "$results_file")"
warn_count="$(awk -F '\t' '$1 == "WARN" {n++} END {print n+0}' "$results_file")"
broken_count="$(awk -F '\t' '$1 == "BROKEN" {n++} END {print n+0}' "$results_file")"

if (( broken_count > 0 )); then
  print -- "\nBroken links:"
  awk -F '\t' '$1 == "BROKEN" {printf "  [%s] %s\n        found on: %s\n", $2, $3, $5}' "$results_file"
fi

if (( warn_count > 0 )); then
  print -- "\nLinks requiring a manual check (access denied or rate limited):"
  awk -F '\t' '$1 == "WARN" {printf "  [%s] %s\n        found on: %s\n", $2, $3, $5}' "$results_file"
fi

if (( ${#crawl_failures[@]} > 0 )); then
  print -- "\nPages that could not be crawled:"
  for failure in "${crawl_failures[@]}"; do
    print -r -- "  ${failure%%$'\t'*}"
  done
fi

if [[ -n "$report_file" ]]; then
  report_dir="${report_file:h}"
  [[ "$report_dir" == "." ]] || mkdir -p -- "$report_dir"
  {
    print -r -- $'result\tstatus\turl\tfinal_url\tfound_on'
    cat "$results_file"
  } > "$report_file"
  print -- "\nReport saved to $report_file"
fi

print -- "\nSummary: $ok_count OK, $warn_count warnings, $broken_count broken; ${#visited_pages} pages crawled."

(( broken_count == 0 && ${#crawl_failures[@]} == 0 ))
