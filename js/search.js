document.addEventListener('DOMContentLoaded', function () {
  const academicSources = [
    {
      rootSelector: '.publications-page',
      headingSelector: '.publication-header ~ h2',
      listClass: 'blue',
      prefix: 'publication',
      type: 'Publication',
      urlKey: 'publicationsUrl'
    },
    {
      rootSelector: '.activity-header',
      headingSelector: '.activity-header ~ h2',
      listClass: 'gold',
      prefix: 'activity',
      type: 'Activity',
      urlKey: 'activitiesUrl'
    }
  ];

  const cleanText = function (value) {
    return String(value || '').replace(/\s+/g, ' ').trim();
  };

  const academicSlug = function (value) {
    return cleanText(value)
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/&/g, ' and ')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '')
      .slice(0, 90);
  };

  const collectAcademicEntries = function (root, source, baseUrl, assignTargets) {
    const entries = [];
    const usedIds = Object.create(null);

    root.querySelectorAll(source.headingSelector).forEach(function (heading) {
      const list = heading.nextElementSibling;
      if (!list || !list.classList.contains(source.listClass)) {
        return;
      }

      const category = cleanText(heading.textContent);
      Array.from(list.children).forEach(function (paragraph) {
        if (paragraph.tagName !== 'P') {
          return;
        }

        const titleNode = paragraph.querySelector('strong.hl');
        if (!titleNode) {
          return;
        }

        const titleWithPunctuation = cleanText(titleNode.textContent);
        const title = titleWithPunctuation.replace(/[.:;]+$/, '');
        const baseId = source.prefix + '-' + (academicSlug(title) || 'entry');
        usedIds[baseId] = (usedIds[baseId] || 0) + 1;
        const id = usedIds[baseId] > 1 ? baseId + '-' + usedIds[baseId] : baseId;
        const fullText = cleanText(paragraph.textContent);
        const description = cleanText(fullText.slice(titleWithPunctuation.length));

        if (assignTargets) {
          paragraph.id = id;
          paragraph.classList.add('academic-search-target');
        }

        entries.push({
          title: title,
          url: baseUrl + '#' + id,
          type: source.type,
          context: category,
          description: description,
          content: fullText,
          tags: [],
          date: ''
        });
      });
    });

    return entries;
  };

  academicSources.forEach(function (source) {
    if (document.querySelector(source.rootSelector)) {
      collectAcademicEntries(document, source, window.location.pathname, true);
    }
  });

  if (window.location.hash) {
    window.requestAnimationFrame(function () {
      let targetId;
      try {
        targetId = decodeURIComponent(window.location.hash.slice(1));
      } catch (error) {
        return;
      }
      const target = document.getElementById(targetId);
      if (target && target.classList.contains('academic-search-target')) {
        target.scrollIntoView({ block: 'start' });
      }
    });
  }

  const dialog = document.getElementById('siteSearchDialog');
  const openButton = document.getElementById('siteSearchOpen');
  const input = document.getElementById('siteSearchInput');
  const results = document.getElementById('siteSearchResults');
  const status = document.getElementById('siteSearchStatus');

  if (!dialog || !openButton || !input || !results || !status) {
    return;
  }

  let searchIndex = null;
  let indexRequest = null;
  let resultLinks = [];
  let activeResult = -1;
  let previouslyFocused = null;

  const normalize = function (value) {
    return String(value || '')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/\s+/g, ' ')
      .trim()
      .toLowerCase();
  };

  const displayText = function (value) {
    return String(value || '')
      .replace(/<[^>]*>/g, ' ')
      .replace(/&nbsp;/g, ' ')
      .replace(/&amp;/g, '&')
      .replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'")
      .replace(/\s+/g, ' ')
      .trim();
  };

  const prepareIndex = function (items) {
    return items.map(function (item) {
      const tags = Array.isArray(item.tags) ? item.tags.join(' ') : '';
      return Object.assign({}, item, {
        normalizedTitle: normalize(item.title),
        normalizedDescription: normalize(item.description),
        normalizedContent: normalize(item.content),
        normalizedTags: normalize(tags),
        normalizedContext: normalize(item.context)
      });
    });
  };

  const loadAcademicEntries = function () {
    return Promise.all(academicSources.map(function (source) {
      const sourceUrl = dialog.dataset[source.urlKey];
      return fetch(sourceUrl, { credentials: 'same-origin' })
        .then(function (response) {
          if (!response.ok) {
            throw new Error(source.type + ' index could not be loaded.');
          }
          return response.text();
        })
        .then(function (html) {
          const parsedPage = new DOMParser().parseFromString(html, 'text/html');
          return collectAcademicEntries(parsedPage, source, sourceUrl, false);
        });
    })).then(function (entryGroups) {
      return entryGroups.reduce(function (allEntries, entries) {
        return allEntries.concat(entries);
      }, []);
    });
  };

  const loadIndex = function () {
    if (searchIndex) {
      return Promise.resolve(searchIndex);
    }

    if (!indexRequest) {
      const pageIndexRequest = fetch(dialog.dataset.searchIndex, { credentials: 'same-origin' })
        .then(function (response) {
          if (!response.ok) {
            throw new Error('Search index could not be loaded.');
          }
          return response.json();
        });

      indexRequest = Promise.all([pageIndexRequest, loadAcademicEntries()])
        .then(function (indexes) {
          searchIndex = prepareIndex(indexes[0].concat(indexes[1]));
          return searchIndex;
        })
        .catch(function (error) {
          indexRequest = null;
          throw error;
        });
    }

    return indexRequest;
  };

  const makeSnippet = function (item, terms) {
    const description = displayText(item.description);
    const content = displayText(item.content);
    const descriptionMatch = terms.some(function (term) {
      return normalize(description).includes(term);
    });
    const useDescription = description && (descriptionMatch || item.type !== 'Journal Entry');
    const source = useDescription ? description : (content || description);

    if (!source) {
      return '';
    }

    const normalizedSource = normalize(source);
    let matchPosition = source.length;
    terms.forEach(function (term) {
      const position = normalizedSource.indexOf(term);
      if (position >= 0 && position < matchPosition) {
        matchPosition = position;
      }
    });

    if (matchPosition === source.length || source.length <= 180) {
      return source.length > 180 ? source.slice(0, 177).replace(/\s+\S*$/, '') + '…' : source;
    }

    const start = Math.max(0, matchPosition - 65);
    const end = Math.min(source.length, matchPosition + 115);
    const snippet = source.slice(start, end)
      .replace(/^\S*\s/, '')
      .replace(/\s\S*$/, '');
    return (start > 0 ? '…' : '') + snippet + (end < source.length ? '…' : '');
  };

  const scoreItem = function (item, terms, phrase) {
    let score = 0;
    const searchable = [
      item.normalizedTitle,
      item.normalizedDescription,
      item.normalizedTags,
      item.normalizedContext,
      item.normalizedContent
    ].join(' ');

    if (!terms.every(function (term) { return searchable.includes(term); })) {
      return 0;
    }

    terms.forEach(function (term) {
      if (item.normalizedTitle.includes(term)) score += 45;
      if (item.normalizedTags.includes(term)) score += 28;
      if (item.normalizedContext.includes(term)) score += 18;
      if (item.normalizedDescription.includes(term)) score += 14;
      if (item.normalizedContent.includes(term)) score += 3;
    });

    if (item.normalizedTitle.includes(phrase)) score += 110;
    if (item.normalizedDescription.includes(phrase)) score += 25;
    if (item.normalizedTags.includes(phrase)) score += 20;
    if (item.normalizedContext.includes(phrase)) score += 18;
    return score;
  };

  const updateActiveResult = function (nextIndex) {
    resultLinks.forEach(function (link) {
      link.classList.remove('is-active');
      link.setAttribute('aria-selected', 'false');
    });

    if (!resultLinks.length) {
      activeResult = -1;
      input.removeAttribute('aria-activedescendant');
      return;
    }

    activeResult = (nextIndex + resultLinks.length) % resultLinks.length;
    const activeLink = resultLinks[activeResult];
    activeLink.classList.add('is-active');
    activeLink.setAttribute('aria-selected', 'true');
    input.setAttribute('aria-activedescendant', activeLink.id);
    activeLink.scrollIntoView({ block: 'nearest' });
  };

  const renderResults = function (query) {
    const phrase = normalize(query);
    const terms = phrase.split(' ').filter(function (term) {
      return term.length > 1;
    });

    results.replaceChildren();
    resultLinks = [];
    activeResult = -1;
    input.removeAttribute('aria-activedescendant');

    if (!phrase || !terms.length) {
      status.textContent = 'Start typing to search.';
      return;
    }

    const matches = searchIndex
      .map(function (item) {
        return { item: item, score: scoreItem(item, terms, phrase) };
      })
      .filter(function (match) { return match.score > 0; })
      .sort(function (a, b) {
        return b.score - a.score || a.item.title.localeCompare(b.item.title);
      })
      .slice(0, 10);

    status.textContent = matches.length
      ? matches.length + (matches.length === 1 ? ' result' : ' results')
      : 'No results found.';

    matches.forEach(function (match, index) {
      const item = match.item;
      const link = document.createElement('a');
      const heading = document.createElement('span');
      const meta = document.createElement('span');
      const type = document.createElement('span');
      const snippet = document.createElement('span');

      link.className = 'site-search-result';
      link.href = item.url;
      link.id = 'siteSearchResult' + index;
      link.setAttribute('role', 'option');
      link.setAttribute('aria-selected', 'false');

      heading.className = 'site-search-result-title';
      heading.textContent = item.title;

      meta.className = 'site-search-result-meta';
      type.className = 'site-search-result-type';
      type.textContent = item.type;
      meta.appendChild(type);
      if (item.context) {
        const context = document.createElement('span');
        context.textContent = item.context;
        meta.appendChild(context);
      }
      if (item.date) {
        const date = document.createElement('span');
        date.textContent = item.date;
        meta.appendChild(date);
      }

      snippet.className = 'site-search-result-snippet';
      snippet.textContent = makeSnippet(item, terms);

      link.append(meta, heading);
      if (snippet.textContent) {
        link.appendChild(snippet);
      }
      link.addEventListener('mouseenter', function () {
        updateActiveResult(index);
      });
      link.addEventListener('click', function () {
        closeSearch();
      });
      results.appendChild(link);
    });

    resultLinks = Array.from(results.querySelectorAll('.site-search-result'));
  };

  const openSearch = function () {
    previouslyFocused = document.activeElement;
    dialog.hidden = false;
    document.body.classList.add('site-search-open');

    const mainNavbar = document.getElementById('main-navbar');
    if (mainNavbar && mainNavbar.classList.contains('in') && window.jQuery) {
      window.jQuery(mainNavbar).collapse('hide');
    }

    window.requestAnimationFrame(function () {
      dialog.classList.add('is-open');
      input.focus();
    });

    status.textContent = 'Loading search…';
    loadIndex()
      .then(function () {
        renderResults(input.value);
      })
      .catch(function () {
        status.textContent = 'Search is temporarily unavailable.';
      });
  };

  const closeSearch = function () {
    dialog.classList.remove('is-open');
    document.body.classList.remove('site-search-open');
    input.removeAttribute('aria-activedescendant');
    window.setTimeout(function () {
      dialog.hidden = true;
      if (previouslyFocused && typeof previouslyFocused.focus === 'function') {
        previouslyFocused.focus();
      }
    }, 180);
  };

  openButton.addEventListener('click', openSearch);
  dialog.querySelectorAll('[data-search-close]').forEach(function (button) {
    button.addEventListener('click', closeSearch);
  });

  input.addEventListener('input', function () {
    if (searchIndex) {
      renderResults(input.value);
    }
  });

  input.addEventListener('keydown', function (event) {
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      updateActiveResult(activeResult + 1);
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      updateActiveResult(activeResult - 1);
    } else if (event.key === 'Enter' && activeResult >= 0) {
      event.preventDefault();
      closeSearch();
      window.location.assign(resultLinks[activeResult].href);
    }
  });

  document.addEventListener('keydown', function (event) {
    const shortcutTarget = event.target;
    const isEditing = shortcutTarget.matches('input, textarea, select, [contenteditable="true"]');

    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') {
      event.preventDefault();
      if (dialog.hidden) {
        openSearch();
      } else {
        input.focus();
      }
      return;
    }

    if (event.key === 'Escape' && !dialog.hidden) {
      event.preventDefault();
      closeSearch();
      return;
    }

    if (!isEditing && event.key === '/' && dialog.hidden) {
      event.preventDefault();
      openSearch();
    }
  });

  dialog.addEventListener('keydown', function (event) {
    if (event.key !== 'Tab') {
      return;
    }

    const focusable = Array.from(dialog.querySelectorAll('button:not([tabindex="-1"]), input, a[href]'));
    if (!focusable.length) {
      return;
    }
    const first = focusable[0];
    const last = focusable[focusable.length - 1];
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first.focus();
    }
  });
});
