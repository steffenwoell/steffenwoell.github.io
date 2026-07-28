// MIT License

document.addEventListener('DOMContentLoaded', function () {
  const navbar = document.querySelector('.navbar-custom');
  const mainNavbar = document.getElementById('main-navbar');

  if (!navbar) {
    return;
  }

  let scrollUpdatePending = false;
  const updateNavbarState = function () {
    navbar.classList.toggle('top-nav-short', window.scrollY > 50);
    scrollUpdatePending = false;
  };

  window.addEventListener('scroll', function () {
    if (!scrollUpdatePending) {
      window.requestAnimationFrame(updateNavbarState);
      scrollUpdatePending = true;
    }
  }, { passive: true });
  updateNavbarState();

  if (mainNavbar && window.jQuery) {
    const collapsibleNavbar = window.jQuery(mainNavbar);
    collapsibleNavbar.on('show.bs.collapse', function () {
      navbar.classList.add('top-nav-expanded');
    });
    collapsibleNavbar.on('hidden.bs.collapse', function () {
      navbar.classList.remove('top-nav-expanded');
    });
  }

  if (mainNavbar) {
    const parentButtons = mainNavbar.querySelectorAll('.navlinks-parent');
    parentButtons.forEach(function (button) {
      button.addEventListener('click', function () {
        parentButtons.forEach(function (otherButton) {
          const shouldExpand = otherButton === button
            ? otherButton.getAttribute('aria-expanded') !== 'true'
            : false;
          otherButton.setAttribute('aria-expanded', String(shouldExpand));
          otherButton.parentElement.classList.toggle('show-children', shouldExpand);
        });
      });
    });
  }
});
