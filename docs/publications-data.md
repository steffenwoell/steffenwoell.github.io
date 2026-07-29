# Publication data model

`_data/publications.yml` is the future canonical source for the Publications
page and its JSON-LD. During the staged migration, `publications.md` remains the
source of the visible page. Do not maintain the same entry in both sources once
the renderer is enabled for its category.

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

## Fields

Required for every entry:

- `id`: unique lowercase ASCII identifier with hyphens
- `category`: an ID declared in the top-level `categories` list
- `schema_type`: supported Schema.org type
- `title`: publication title without trailing display punctuation
- `authors`: list of people with at least a `name`
- `status`: `published`, `in_press`, `forthcoming`, or `in_progress`
- `links`: list; use `[]` when no link exists

Common optional fields:

```yaml
date: 2023-09-01
year: 2023
peer_reviewed: true
editors:
  - name: Jane Example
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
bundle exec jekyll build
```

The validator checks the data contract and compares the legacy markup with
`_data/publications-baseline.yml`. Refreshing that baseline is an intentional
operation and should only happen after reviewing changes to the legacy list:

```sh
bundle exec ruby scripts/validate_publications.rb --refresh-baseline
```
