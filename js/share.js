(function () {
  'use strict';

  const shareButton = document.querySelector('.journal-share-button');
  if (!shareButton) return;

  const label = shareButton.querySelector('[data-share-label]');
  const status = document.getElementById('journalShareStatus');
  const originalLabel = label ? label.textContent : 'Share';
  let resetTimer;

  const setStatus = function (message, copied) {
    window.clearTimeout(resetTimer);
    if (label) label.textContent = message;
    if (status) status.textContent = message;
    shareButton.classList.add('has-status');
    shareButton.classList.toggle('is-copied', Boolean(copied));

    resetTimer = window.setTimeout(function () {
      if (label) label.textContent = originalLabel;
      if (status) status.textContent = '';
      shareButton.classList.remove('has-status');
      shareButton.classList.remove('is-copied');
    }, 2200);
  };

  const copyText = async function (text) {
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(text);
      return;
    }

    const input = document.createElement('textarea');
    input.value = text;
    input.setAttribute('readonly', '');
    input.style.position = 'fixed';
    input.style.opacity = '0';
    document.body.appendChild(input);
    input.select();
    const copied = document.execCommand('copy');
    input.remove();
    if (!copied) throw new Error('Copy failed');
  };

  shareButton.addEventListener('click', async function () {
    const shareData = {
      title: shareButton.dataset.shareTitle || document.title,
      text: 'Journal entry by Steffen Wöll',
      url: shareButton.dataset.shareUrl || window.location.href
    };

    if (typeof navigator.share === 'function') {
      try {
        await navigator.share(shareData);
        return;
      } catch (error) {
        if (error && error.name === 'AbortError') return;
      }
    }

    try {
      await copyText(shareData.url);
      setStatus('Link copied', true);
    } catch (error) {
      setStatus('Copy failed', false);
    }
  });
}());
