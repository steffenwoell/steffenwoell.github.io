# Publication citation function: Phase 1

Phase 1 defines and audits the bibliographic contract. It does not add a
visible citation control to the website.

## Initial scope

The first implementation will support:

- published books;
- scholarly journal articles;
- published, in-press, and forthcoming book chapters;
- Chicago Notes and Bibliography, MLA 9, and BibTeX output.

The in-progress habilitation project is deliberately excluded until it has
stable publication metadata. Reviews, working papers, digital projects, media,
posters, web projects, and early work belong to later phases.

## Readiness result

The original Phase 1 scope contained 27 citation-ready records:

- 2 books;
- 14 scholarly journal articles;
- 11 book chapters.

No entry in this scope is blocked by missing required metadata. Missing DOI,
page, volume, or editor information is treated as a documented fallback rather
than fabricated. The audit reports these omissions so they can still be
improved later.

Person names remain stored as full display names. Phase 2 must format these
conservatively and provide explicit name-part overrides before attempting to
invert ambiguous multi-part surnames.

## Data and fixtures

- `_data/publication-citation.yml` defines supported types, statuses, styles,
  required metadata, and fallback behavior.
- `_data/publication-citation-cases.yml` contains manually reviewed target
  strings for a book, a journal article, and a chapter.
- `scripts/audit_publication_citations.rb` checks readiness and fixture
  integrity without changing the public site.

Run the audit with:

```sh
bundle exec ruby scripts/audit_publication_citations.rb
```

Phase 2 should implement generators against these fixtures before any citation
button is exposed publicly.

Phase 2 is documented separately in `docs/publication-citations-phase-2.md`.
