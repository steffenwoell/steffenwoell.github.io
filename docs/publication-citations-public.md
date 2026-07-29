# Public publication citations

The Publications page exposes 56 of the 57 structured records through a static,
GitHub-Pages-compatible citation dialog.

## Build-time data

`scripts/generate_publication_citations.rb` writes the reviewed generator output
to `_data/publication-citations-generated.yml`. Regenerate it after changing
citation-relevant publication or person metadata:

```sh
bundle exec ruby scripts/generate_publication_citations.rb
```

CI or local checks should use the non-writing freshness check:

```sh
bundle exec ruby scripts/generate_publication_citations.rb --check
```

## Automatic refresh before commits

This repository uses the tracked `.githooks/pre-commit` hook. Before every
local commit, the hook regenerates `_data/publication-citations-generated.yml`
and stages that generated file for the same commit. A generator error stops the
commit rather than committing stale citation data.

Enable the tracked hooks once after cloning the repository:

```bash
git config core.hooksPath .githooks
```

## Public interaction

Supported publication entries receive a `Cite` button. The dialog provides:

- Chicago bibliography (Notes and Bibliography), MLA 9, and BibTeX tabs;
- semantic citation display;
- clipboard copy with a legacy-browser fallback;
- individual BibTeX, RIS, and CSL-JSON downloads;
- Escape, outside-click, arrow-key, and focus-loop keyboard behavior;
- a compact mobile bottom sheet;
- reduced-motion support.

The Publications header additionally offers complete-list downloads in
BibTeX, RIS, and CSL-JSON. The browser assembles them from the same generated
records as the individual dialog, so no second publication list is maintained.

Unsupported publication categories do not receive an inactive control.
JavaScript failure leaves the original publication list and links intact.

The `Cite` control is always placed on its own row beneath the final
bibliographic or external-link line.

The current public scope comprises books, edited journal issues, journal
articles, book chapters, working papers, reviews, datasets, digital documents,
maps, media articles, blog posts, video, posters, websites, and early
unrefereed papers. Classic BibTeX uses conservative standard fallbacks where it
does not define a dedicated modern type.

The in-progress habilitation project is deliberately excluded. A citation
control would imply a stable, citable publication state that the project does
not yet have.

RIS and CSL-JSON are generated from the same structured publication records.
They preserve separate given and family names, prefer dedicated DOI fields,
retain a non-DOI URL where available, and omit unknown values. Download
filenames use the same stable key as BibTeX.
Site-local document links are expanded to canonical public URLs during
generation.
