(() => {
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));

  // Nav: drop shadow once the page has scrolled
  const nav = $('#nav');
  const onScroll = () => nav && nav.classList.toggle('scrolled', window.scrollY > 4);
  onScroll();
  window.addEventListener('scroll', onScroll, { passive: true });

  // Mobile menu
  const menuBtn = $('.menu-btn');
  if (nav && menuBtn) {
    menuBtn.addEventListener('click', () => {
      const open = nav.classList.toggle('open');
      menuBtn.setAttribute('aria-expanded', String(open));
    });
    $$('.nav-links a').forEach(a => a.addEventListener('click', () => {
      nav.classList.remove('open');
      menuBtn.setAttribute('aria-expanded', 'false');
    }));
  }

  // Highlight whichever section is nearest the top of the viewport
  const links = $$('.nav-links a[href^="#"]');
  const sections = links.map(a => $(a.getAttribute('href'))).filter(Boolean);
  if (sections.length) {
    const spy = () => {
      let current = sections[0];
      for (const s of sections) {
        if (s.getBoundingClientRect().top <= 120) current = s;
      }
      links.forEach(a => a.classList.toggle('active', a.getAttribute('href') === `#${current.id}`));
    };
    spy();
    window.addEventListener('scroll', spy, { passive: true });
    window.addEventListener('resize', spy);
  }

  // Photos not added yet show a placeholder instead of a broken image.
  // Checks complete/naturalWidth too, since a missing image can error before this script runs.
  const placeholder = img => {
    const ph = document.createElement('div');
    ph.className = 'ph';
    ph.setAttribute('aria-hidden', 'true');
    const figure = img.closest('figure');
    if (figure) figure.classList.add('is-ph');
    img.replaceWith(ph);
  };
  $$('img[data-ph]').forEach(img => {
    if (img.complete && img.naturalWidth === 0) placeholder(img);
    else img.addEventListener('error', () => placeholder(img));
  });

  // News: show older items
  const more = $('#news-more');
  if (more) {
    more.addEventListener('click', () => {
      const hidden = $$('#news-list li.hidden');
      hidden.forEach(li => li.classList.remove('hidden'));
      if (hidden[0]) {
        hidden[0].setAttribute('tabindex', '-1');
        hidden[0].focus();
      }
      more.remove();
    });
  }

  const year = $('#year');
  if (year) year.textContent = String(new Date().getFullYear());
})();
