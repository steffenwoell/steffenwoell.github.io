# Publication citation quality

The public citation output uses three deliberately named formats:

- Chicago bibliography, following the Notes and Bibliography system;
- MLA 9;
- BibTeX.

The generator follows the official quick-reference rules for author order,
multiple authors, editors, page ranges, DOI preference, and access URLs:

- [Chicago Citation Quick Guide](https://www.chicagomanualofstyle.org/tools_citationguide.html)
- [MLA Style Center](https://style.mla.org/)
- [BibTeX documentation](https://ctan.org/pkg/bibtex)

## Style-specific treatment

- Chicago bibliography entries put article, review, presentation, poster,
  manuscript, and video titles in quotation marks. Book, report, dataset, map,
  and other standalone-work titles are italicized.
- Chicago treats the title of a special journal issue as a quoted title and
  identifies it as a special issue of the italicized journal. MLA uses
  `Special issue of` and italicizes both the issue title and journal title.
- Chicago online dates use `Month Day, Year`; MLA dates use
  `Day abbreviated-Month Year`.
- MLA conference presentations and unpublished manuscripts use quotation marks
  around the work title and identify the event or institution as the container.
- MLA abbreviates academic publisher names containing `University Press`
  (`Coimbra UP`, `U of Chicago P`) and changes an ampersand or plus sign in a
  publisher name to `and`. Chicago retains the publisher's full name.
- Whole websites retain their documented publication date range. MLA
  italicizes the site title; Chicago treats the site name as the author when
  both are identical and does not repeat it as an italicized title.
- Forthcoming and in-press prose citations say `forthcoming` instead of
  presenting an expected year as a confirmed publication year. Expected years
  remain available in the structured export data.

## Implementation safeguards

- Permanent publication IDs, rather than mutable titles, seed BibTeX keys.
- Duplicate keys receive deterministic alphabetical suffixes.
- BibTeX names use `family, given` form and preserve multi-part family names.
- Titles and container titles receive an extra brace layer to preserve
  capitalization.
- BibTeX-sensitive characters are escaped.
- A DOI is preferred; a verified HTTPS URL is used only when no DOI exists.
- Forthcoming and in-press records retain an expected year plus an explicit
  status note.
- Unknown metadata remains absent rather than being inferred.
- Edited journal issues use BibTeX `@misc`, working papers use `@techreport`,
  and reviews use `@article`.
- RIS uses CRLF record lines and an explicit `ER  -` terminator.
- CSL-JSON keeps contributor names structured and emits a raw DOI rather than
  a DOI resolver URL.
- Datasets, maps, digital documents, articles, blog posts, video, posters,
  websites, and manuscripts use explicit RIS and CSL type mappings.
- Classic BibTeX represents seminar papers as `@unpublished`; heterogeneous
  digital and visual works use the conservative `@misc` fallback.
- Relative site files become canonical `https://steffenwoell.github.io` URLs.

`scripts/test_publication_citations.rb` checks exact reference fixtures and
additional edge cases for multiple authors and editors, nested quotation marks,
Roman page ranges, status fallbacks, HTML escaping, stable keys, BibTeX
escaping, edited issues, working papers, reviews, and undated forthcoming work.
Every eligible record is additionally parsed as CSL-JSON and checked for a
valid RIS header, record terminator, and line-ending structure.

The citation audit may report recommended metadata gaps. These are non-blocking
when the source information is genuinely unknown, especially for forthcoming
work. They should not be filled with placeholders.
