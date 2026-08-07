# steffenwoell.github.io

Source code and content for the personal academic website of
[Dr. Steffen Wöll](https://steffenwoell.github.io).

The website includes publications, conference activities, research interests,
and journal posts.

## Technology

- Jekyll
- Markdown, HTML, CSS, JavaScript
- Bootstrap 3
- jQuery
- Font Awesome (self-hosted)

The site does not use analytics, cookies or tracking technologies.

## Project structure

```text
_data/       Structured data used by templates
_includes/   Reusable Liquid and HTML components
_layouts/    Page and post layouts
_posts/      Journal posts
css/         Site styles, Bootstrap, fonts, and Font Awesome
doc/         Publications, keys, and legal documents
img/         Images and favicons
journal/     Journal index
js/          Site scripts and local JavaScript dependencies
```

Site-wide settings, navigation links, pagination, exclusions, and plugins are
configured in `_config.yml`.

## Local development

### Requirements

- Ruby 3.0 or newer
- Bundler

Install the dependencies:

```bash
bundle install
```

Start the local development server:

```bash
bundle exec jekyll serve --livereload
```

The website will normally be available at
<http://localhost:4000>.

To perform a production-style build without starting a server:

```bash
bundle exec jekyll build
```

The generated site is written to `_site/`, which is excluded from version
control.

## Features & Accessibility

The site includes:

- keyboard-accessible navigation, dialogs, search, and theme controls
- light and dark color schemes
- reduced-motion support
- semantic labels for controls and decorative icons
- responsive layouts for smaller screens
- language metadata for German and English journal entries

Before publishing substantial layout or interaction changes, check:

- keyboard navigation forwards and backwards with `Tab` and `Shift` + `Tab`
- Safari with VoiceOver using landmarks, headings, links, and form controls
- search and citation dialogs, including focus return after closing
- browser zoom at 200% and 400%
- reflow at a viewport width of 320 CSS pixels
- light mode, dark mode, reduced motion, and increased contrast
- the principal content with JavaScript disabled

Journal posts inherit English from the site configuration. Add `lang: de` to
the front matter of German-language posts so browsers and screen readers use
the appropriate pronunciation.

## Link checking

Check all internal and external links on the published website:

```bash
scripts/check-site-links.zsh
```

The checker crawls the site's internal pages and tests the discovered links in
parallel. To check a locally running Jekyll build instead, use:

```bash
scripts/check-site-links.zsh --url http://localhost:4000/
```

Run `scripts/check-site-links.zsh --help` for options such as external-only
checks and tab-separated reports. The command exits with a non-zero status when
it finds a broken link or cannot crawl an internal page.

## Project release versions

Update the software versions shown on the landing page from the latest public
GitHub releases:

```bash
scripts/update-project-versions.zsh
```

The updater reads the repositories configured in `_data/projects.yml`. It
removes a leading `v` from each release tag and updates a codename only when the
first release heading contains one in quotation marks. Existing data is left
unchanged if any request or validation fails. Preview changes without writing
the YAML file with:

```bash
scripts/update-project-versions.zsh --dry-run
```

An optional `GITHUB_TOKEN` environment variable can be used for authenticated
GitHub API requests.

## Licenses and attribution

Unless otherwise stated, the website content is licensed under
[Creative Commons BY-NC-ND 4.0](doc/legal/CC-LICENSE.txt).

Third-party components and assets retain their respective licenses. Details are
listed on the [contact and legal information page](contact.md).
