# Publication citation function: Phase 2

Phase 2 implements the local citation engine without adding a public control,
browser JavaScript, or an internal preview page.

## Components

- `lib/publication_citations.rb` normalizes and formats publication records.
- `_data/publication-people.yml` provides explicit given and family name parts.
- `scripts/test_publication_citations.rb` runs exact fixtures and synthetic
  regression cases.

The generator supports:

- Chicago Notes and Bibliography;
- MLA 9;
- BibTeX;
- plain text and semantic HTML using `<cite>`;
- books, scholarly journal articles, and book chapters;
- DOI and best-external-link fallbacks;
- missing page, volume, and editor metadata;
- forthcoming and in-press records;
- stable BibTeX keys with deterministic collision suffixes;
- an optional explicit `citation_key` override.

## Name handling

Names are never split heuristically. The people registry contains reviewed
given and family name parts for all contributors in the initial scope,
including particles and multi-part surnames such as `da Silva`,
`Vale de Gato`, and `Dreysse Passos de Carvalho`.

## Local verification

Run:

```sh
bundle exec ruby scripts/validate_publications.rb
bundle exec ruby scripts/audit_publication_citations.rb
bundle exec ruby scripts/test_publication_citations.rb
bundle exec jekyll build
```

The regression suite checks nine exact target strings, generates all three
formats for all currently eligible records, verifies semantic HTML, exercises complex
names and status fallbacks, and requires unique deterministic BibTeX keys.

This document records the generator milestone. Its later public integration is
documented in `docs/publication-citations-public.md`.
