# Publication data model

`_data/publications.yml` is the canonical source for the Publications page and
its JSON-LD. `publications.md` contains the page header and renders the
navigation, sections, citations, links, and structured metadata from that data
file.

## Minimal entry

```yaml
- id: unmasking-maps-unmaking-empire
  category: journals
  schema_type: ScholarlyArticle
  title: "Unmasking Maps, Unmaking Empire: Towards an Archipelagic Cartography"
  authors:
    - name: Steffen Wöll
  year: 2023
  status: published
  links:
    - label: Open Access
      url: https://doi.org/10.5070/T814160835
      access: open
```

The `id` is permanent. It is used for page anchors, search results, and JSON-LD
identifiers and must not be changed when a title is edited.

## Featured presentation

An existing entry can be presented separately above the regular categories
without creating a new publication type:

```yaml
featured:
  habilitation:
    label: Habilitation Project
    entry_id: publication-a-place-between-oceans-imagining-american-empire-1880-1940
```

The referenced entry remains in its canonical category for the data inventory,
JSON-LD, search, and future citation exports. The Publications page renders it
only in the featured section and excludes it from the repeated category list.
The validator checks that every featured reference points to an existing entry.

## Fields

Required for every entry:

- `id`: unique lowercase ASCII identifier with hyphens
- `category`: an ID declared in the top-level `categories` list
- `schema_type`: supported Schema.org type
- `title`: publication title without trailing display punctuation
- `authors` or `editors`: at least one person with a `name`
- `status`: `published`, `in_press`, `forthcoming`, `in_progress`, or `ongoing`
- `links`: list; use `[]` when no link exists

Common optional fields:

```yaml
date: 2023-09-01
year: 2023
peer_reviewed: true
editors:
  - name: Jane Example
contribution_role: co_editor
volume: "8"
container:
  title: Journal or collected-volume title
  volume: "14"
  issue: "1"
pages:
  start: 137
  end: 167
publisher:
  name: Example Press
series:
  title: Example Series
  volume: "5"
doi: 10.5070/T814160835
note: Free text only for information without a dedicated field
```

Book chapters use a nested book record. Expected years are kept separate from
actual publication years:

```yaml
status: forthcoming
expected_year: 2027
book:
  title: Collected volume title
  editors:
    - name: Jane Example
```

`expected_year` is displayed with the status but is never emitted as
`datePublished`.

Reviews retain their visible citation title and describe the reviewed book
separately:

```yaml
schema_type: Review
item_reviewed:
  title: Reviewed book title
  authors:
    - name: Book Author
```

Heterogeneous projects may use a restricted text-only display mapping:

```yaml
display:
  date: 2018/2022
  detail: GlobeData
  organization: Example institution
  status: Habilitation project
```

Only these four fields are allowed. Structured lifecycle fields such as
`date_created`, `date_modified`, and `start_year` remain the source for JSON-LD;
the display mapping never creates `datePublished`.

Display exceptions should remain rare. `contributors_position: after_citation`,
`year_format: plain`, `preserve_title_punctuation: true`, and a custom
`pages.separator` preserve established citation forms without embedding HTML in
the data.

Media and outreach entries may use a `media` mapping for outlet, section,
medium, or credit information. Early work may use `academic_context` for the
course and instructor. Keep these mappings factual and omit unknown fields.

Each link has a label, URL, and access type:

```yaml
links:
  - label: Open Access
    url: https://doi.org/10.5070/T814160835
    access: open
```

Allowed access values are `open`, `print`, `publisher`, `file`, and `web`.
Site-local URLs begin with `/`; external URLs must use HTTPS.

Use `CreativeWork` when the exact Schema.org type is uncertain. Do not guess a
more specific type solely to make the structured data appear more detailed.

## Validation

Run both checks before and after each migration step:

```sh
bundle exec ruby scripts/validate_publications.rb
bundle exec ruby scripts/audit_publication_citations.rb
bundle exec ruby scripts/test_publication_citations.rb
bundle exec ruby scripts/generate_publication_citations.rb --check
bundle exec jekyll build
```

The generated citation payload also contains BibTeX, RIS, and CSL-JSON export
files. These exports are derived automatically; do not maintain them by hand.
All completed or publicly accessible records are currently exportable. The
in-progress habilitation project remains intentionally outside the citation
scope until it has a stable publication form.

The validator checks the data contract and compares all structured publication
IDs with the frozen migration inventory in
`_data/publications-baseline.yml`. Academic service such as peer reviewing is
maintained on the Activities page and is deliberately absent from this
publication inventory. The baseline should not be regenerated for ordinary
publication updates. Add new entries directly to `_data/publications.yml`.

The citation audit covers the deliberately limited first implementation scope.
Its contract, fallbacks, and reference cases are documented in
`docs/publication-citations-phase-1.md`. The local generator and its regression
suite are documented in `docs/publication-citations-phase-2.md`.
The public dialog and generated-data workflow are documented in
`docs/publication-citations-public.md`.
Formatting decisions and bibliographic quality checks are documented in
`docs/publication-citations-quality.md`.
