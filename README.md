# Tommy S. Liu, personal site

Plain HTML / CSS / JS. No build step.

```
index.html        single page: intro (with island/sailboat scene), education, projects & publications,
                  experience, awards & honors, news, violin, blog, gallery, contact
blog/             essay pages (olympiad-cheating.html, uc-meritocracy.html)
styles.css        Wind Waker-inspired theme (sky, sea-chart grid, cream panels); colour tokens at the top
main.js           sticky-nav state, mobile menu, section highlighting, "show older news"
img/              photos (see to-do)
og-image.png      social preview card
404.html          not-found page (Vercel picks it up automatically)
vercel.json       cleanUrls -> /blog/uc-meritocracy works without .html
```

## Preview locally

Any static server works. Without Node, use the bundled PowerShell server:

```
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/serve.ps1
```

then open http://localhost:5500. With Node installed: `npx serve .`

## Deploy

Push to GitHub and import the repo in Vercel (framework preset **Other**, no build command,
output directory `.`), or run `vercel` from this folder after `npm i -g vercel && vercel login`.

## Images

Every image is already referenced in `index.html`. Save the files into `img/` with these exact
names and they appear on the next reload; until then each one shows a striped placeholder.

```
img/oscilloscope.png        oscilloscope schematic (Projects)
img/panslab.jpg             turbine / supercapacitor bench photo (Projects)
img/gallery-yc.jpg          YC Startup School 2026
img/gallery-hawaii.jpg      Hawaii 2026 senior trip
img/gallery-graduation.jpg  Graduation
img/gallery-uiuc.jpg        Next 4 @ UIUC meetup
img/tommy.jpg               optional headshot (see the comment in index.html)
```

## Other to-dos before launch

- Add `resume.pdf` and un-comment the Resume link in `index.html` (nav).
- Add an absolute `og:image` meta tag once the domain / Vercel URL is known.
