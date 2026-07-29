document.addEventListener('DOMContentLoaded', function () {
  const dialog = document.getElementById('publicationCitationDialog');
  const dataElement = document.getElementById('publicationCitationData');
  const openButtons = Array.from(document.querySelectorAll('[data-citation-open]'));
  if (!dialog || !dataElement || !openButtons.length) return;

  let citations;
  try {
    citations = JSON.parse(dataElement.textContent);
  } catch (error) {
    return;
  }
  openButtons.forEach(function (button) { button.hidden = false; });

  const title = document.getElementById('citationDialogTitle');
  const output = document.getElementById('citationDialogOutput');
  const status = document.getElementById('citationDialogStatus');
  const copyButton = document.getElementById('citationCopyButton');
  const downloadButtons = Array.from(dialog.querySelectorAll('[data-citation-download]'));
  const tabs = Array.from(dialog.querySelectorAll('[data-citation-style]'));
  let currentRecord = null;
  let currentStyle = 'chicago';
  let previouslyFocused = null;

  const copyText = function (text) {
    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      const field = document.createElement('textarea');
      field.value = text;
      field.readOnly = true;
      field.style.position = 'fixed';
      field.style.opacity = '0';
      document.body.appendChild(field);
      field.select();
      try {
        document.execCommand('copy') ? resolve() : reject(new Error('Copy failed'));
      } catch (error) {
        reject(error);
      } finally {
        field.remove();
      }
    });
  };

  const styleLabel = function (style) {
    return style === 'mla' ? 'MLA' : (style === 'bibtex' ? 'BibTeX' : 'Chicago bibliography');
  };

  const plainCitation = function () {
    if (currentStyle === 'bibtex') return currentRecord.bibtex;
    return currentRecord[currentStyle].plain;
  };

  const render = function () {
    tabs.forEach(function (tab) {
      const active = tab.dataset.citationStyle === currentStyle;
      tab.setAttribute('aria-selected', String(active));
      tab.tabIndex = active ? 0 : -1;
    });
    const activeTab = tabs.find(function (tab) { return tab.dataset.citationStyle === currentStyle; });
    output.setAttribute('aria-labelledby', activeTab.id);
    output.classList.toggle('is-bibtex', currentStyle === 'bibtex');
    if (currentStyle === 'bibtex') {
      const pre = document.createElement('pre');
      const code = document.createElement('code');
      code.textContent = currentRecord.bibtex;
      pre.appendChild(code);
      output.replaceChildren(pre);
    } else {
      output.innerHTML = currentRecord[currentStyle].html;
    }
    status.textContent = styleLabel(currentStyle) + ' citation selected.';
    copyButton.querySelector('span').textContent = 'Copy citation';
  };

  const open = function (button) {
    currentRecord = citations[button.dataset.citationOpen];
    if (!currentRecord) return;
    currentStyle = 'chicago';
    previouslyFocused = button;
    title.textContent = currentRecord.title;
    render();
    dialog.hidden = false;
    document.body.classList.add('citation-dialog-open');
    window.requestAnimationFrame(function () {
      dialog.classList.add('is-open');
      tabs[0].focus();
    });
  };

  const close = function () {
    dialog.classList.remove('is-open');
    document.body.classList.remove('citation-dialog-open');
    window.setTimeout(function () {
      dialog.hidden = true;
      if (previouslyFocused) previouslyFocused.focus();
    }, 180);
  };

  openButtons.forEach(function (button) {
    button.addEventListener('click', function () { open(button); });
  });
  dialog.querySelectorAll('[data-citation-close]').forEach(function (button) {
    button.addEventListener('click', close);
  });
  tabs.forEach(function (tab, index) {
    tab.addEventListener('click', function () {
      currentStyle = tab.dataset.citationStyle;
      render();
    });
    tab.addEventListener('keydown', function (event) {
      if (event.key !== 'ArrowLeft' && event.key !== 'ArrowRight') return;
      event.preventDefault();
      const direction = event.key === 'ArrowRight' ? 1 : -1;
      tabs[(index + direction + tabs.length) % tabs.length].click();
      tabs[(index + direction + tabs.length) % tabs.length].focus();
    });
  });
  copyButton.addEventListener('click', function () {
    copyText(plainCitation()).then(function () {
      copyButton.querySelector('span').textContent = 'Copied';
      status.textContent = styleLabel(currentStyle) + ' citation copied.';
    }).catch(function () {
      status.textContent = 'Citation could not be copied.';
    });
  });
  downloadButtons.forEach(function (button) {
    button.addEventListener('click', function () {
      const format = button.dataset.citationDownload;
      const download = currentRecord.downloads && currentRecord.downloads[format];
      if (!download) {
        status.textContent = 'Export file is unavailable.';
        return;
      }
      const blob = new Blob([download.content], { type: download.mime_type });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = download.filename;
      document.body.appendChild(link);
      link.click();
      link.remove();
      URL.revokeObjectURL(url);
      status.textContent = button.textContent.trim() + ' file downloaded.';
    });
  });
  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape' && !dialog.hidden) {
      event.preventDefault();
      close();
    }
  });
  dialog.addEventListener('keydown', function (event) {
    if (event.key !== 'Tab') return;
    const focusable = Array.from(dialog.querySelectorAll('button:not([hidden]):not([tabindex="-1"])'));
    if (!focusable.length) return;
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
