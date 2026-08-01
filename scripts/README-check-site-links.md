# Site Link Checker

`check-site-links.zsh` crawls the published website or a local Jekyll build,
discovers HTTP and HTTPS links, and checks them in parallel. It can also locate,
replace, or remove broken external links in the project's source files.

## Requirements

- macOS or another system with Zsh
- `curl`
- Ruby (standard library only)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`)

On macOS, ripgrep can be installed with Homebrew:

```bash
brew install ripgrep
```

Run all commands from the repository root. The script is already executable, so
it does not need to be invoked through `zsh`.

## Basic use

Check all links on the published website:

```bash
scripts/check-site-links.zsh
```

Check a locally running Jekyll build:

```bash
bundle exec jekyll serve
scripts/check-site-links.zsh --url http://localhost:4000/
```

Check only links that point to external websites:

```bash
scripts/check-site-links.zsh --external-only
```

The checker first crawls every internal HTML page it can discover. It then
checks each unique link, follows redirects, and prints the page on which the
link was found.

## Results

Results are divided into three groups:

- `OK`: successful responses and redirects (`2xx` and `3xx`)
- `WARN`: authentication, access, or rate-limit responses (`401`, `403`, and
  `429`) that require a manual browser check
- `BROKEN`: definite errors such as `404` or `410`, network failures, and other
  unsuccessful responses

Some websites reject automated `HEAD` requests even though the link works in a
browser. The script therefore retries `000`, `403`, and `405` responses with a
small ranged `GET` request. Remaining warnings should not be removed solely on
the basis of the automated result.

The command exits with a non-zero status if a link is broken or an internal page
could not be crawled. This makes it suitable for other local scripts, while
warnings alone do not make the check fail.

## Reports

Write the complete result to a tab-separated file:

```bash
scripts/check-site-links.zsh --report link-report.tsv
```

The report records the classification, HTTP status, original URL, final URL
after redirects, and the page on which the link was discovered. It can be
opened in a spreadsheet application or processed by another script.

## Previewing source changes

Repair commands are previews by default. They show matching source locations
without changing any files.

Preview an exact URL replacement:

```bash
scripts/check-site-links.zsh \
  --replace 'https://old.example/page' 'https://new.example/page'
```

Preview the removal of a link:

```bash
scripts/check-site-links.zsh --unlink 'https://example.org/missing'
```

For Markdown and HTML links, `--unlink` preserves the visible link text where
possible. For example, `[Conference](URL)` becomes `Conference`. On
`activities.md`, an unavailable action remains visible as a disabled action box
without an external-link icon. A URL-valued YAML field is removed as a complete
line when it can be identified safely.

## Applying source changes

Add `--apply` only after reviewing the preview:

```bash
scripts/check-site-links.zsh \
  --replace 'https://old.example/page' 'https://new.example/page' \
  --apply
```

To remove the target while retaining its visible text:

```bash
scripts/check-site-links.zsh \
  --unlink 'https://example.org/missing' \
  --apply
```

Every write operation first copies the affected files to a unique backup
directory in the system's temporary folder. The script prints that directory
after completing the change. It then writes each changed source file through a
temporary file and an atomic rename.

Always inspect the result afterwards:

```bash
git diff
scripts/check-site-links.zsh --external-only
```

## Interactive repair

The checker can collect definite broken responses and review their source
occurrences one by one:

```bash
scripts/check-site-links.zsh --external-only --fix-status 404 --apply
```

`--fix` is a shorthand for `--fix-status 404`:

```bash
scripts/check-site-links.zsh --external-only --fix --apply
```

For each matching link, the menu offers these actions:

- `r`: replace it with a new HTTP or HTTPS URL
- `u`: remove the link while preserving its visible text where possible
- `s`: skip it
- `q`: stop the repair session

Without `--apply`, the same command only lists the repair candidates. Interactive
repair is deliberately restricted to the definitive `404` and `410` status
codes. It is not offered for temporary failures, access restrictions, or rate
limits.

## Options

| Option | Purpose |
| --- | --- |
| `-u`, `--url URL` | Set the website to crawl. |
| `-j`, `--jobs NUMBER` | Set the number of parallel checks; the default is `8`. |
| `-t`, `--timeout SEC` | Set the timeout for each request; the default is `20`. |
| `-o`, `--report FILE` | Save a tab-separated report. |
| `--external-only` | Check only external links after crawling internal pages. |
| `--replace OLD NEW` | Locate or replace an exact URL. |
| `--unlink URL` | Remove a link while preserving visible text where possible. |
| `--fix-status CODE` | Review links returning `404` or `410`. |
| `--fix` | Equivalent to `--fix-status 404`. |
| `--apply` | Apply the requested source changes. |
| `-h`, `--help` | Display the built-in command summary. |

## Safety boundaries

- No source file is changed unless `--apply` is present.
- Direct replacement and unlinking use exact URL matches.
- Interactive changes require a terminal and explicit confirmation for every
  candidate.
- `_site/`, `.git/`, `vendor/`, `Gemfile.lock`, and generated output are excluded
  from source modification.
- The script never removes a link merely because it returns `401`, `403`, or
  `429`.
- Backups in the temporary directory are supplementary; Git remains the primary
  way to review or revert project changes.

## Troubleshooting

If a link works in a browser but appears under `WARN`, the remote website may be
blocking automated requests. Check it manually and leave it unchanged unless
the destination is genuinely unavailable.

If a URL is reported as broken but no source occurrence is found, it may have
been generated by a template, normalized during the Jekyll build, or assembled
from structured data. Use the reported source page and search the repository for
a distinctive part of the URL.

To reduce load on remote websites or work around unstable connections, lower
the number of parallel requests and increase the timeout:

```bash
scripts/check-site-links.zsh --jobs 4 --timeout 30
```
