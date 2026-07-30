# steffenwoell.github.io

Source code and content for the personal academic website of
[Dr. Steffen Wöll](https://steffenwoell.github.io).

The website presents publications, conference activities, research interests,
and journal posts. It is built as a static Jekyll site and hosted with GitHub
Pages.

## Technology

- Jekyll and GitHub Pages
- Markdown, HTML, CSS, and JavaScript
- Bootstrap 3
- jQuery
- self-hosted Font Awesome icons
- self-hosted web fonts

The site does not use analytics or tracking technologies and does not set
cookies. The selected color scheme is stored locally in the visitor's browser.

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

The primary content pages are:

- `index.html`
- `publications.md`
- `activities.md`
- `contact.md`

Site-wide settings, navigation links, pagination, exclusions, and plugins are
configured in `_config.yml`.

## Deployment

GitHub Pages builds and publishes the site from the repository. Pushing changes
to the configured publishing source triggers a new deployment.

Before publishing, it is useful to run:

```bash
bundle exec jekyll build
```

## Accessibility

The site includes:

- keyboard-accessible navigation, dialogs, search, and theme controls
- a skip link to bypass repeated navigation
- light and dark color schemes
- reduced-motion support through `prefers-reduced-motion`
- reduced-transparency and forced-colors fallbacks
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

## Licenses and attribution

Unless otherwise stated, the website content is licensed under
[Creative Commons BY-NC-ND 4.0](doc/legal/CC-LICENSE.txt).

Third-party components and assets retain their respective licenses. Details are
listed on the [contact and legal information page](contact.md) and in
`doc/legal/`.
