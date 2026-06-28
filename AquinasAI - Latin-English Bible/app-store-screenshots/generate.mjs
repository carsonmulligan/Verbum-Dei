// Build App Store screenshots (1290x2796, iPhone 6.7") by compositing the real
// app captures into branded "illuminated-manuscript" marketing frames, then
// screenshotting each slide with headless Chrome.
import { writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const DIR = dirname(fileURLToPath(import.meta.url));
const OUT = join(DIR, 'out');
if (!existsSync(OUT)) mkdirSync(OUT);

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

// kicker, headline (use *word* for gold italic emphasis), optional sub, image, dark?
const SLIDES = [
  ['Your daily rhythm',     'A sacred place to *begin* each day',        'Today opens to the Rosary and your daily prayers.', '1rosary.png',            true],
  ['Pray along — or listen', 'The whole Rosary, *read aloud*',           'Latin, English & Español. Three authentic voices.', '2rosary.png',            true],
  ['The Vulgate, parallel', 'Scripture in your *mother tongue*',         'Saint Jerome’s Latin beside the translation you know.', '4biblelatinenglish.png', true],
  ['A living library',      'Every prayer, *voiced* with reverence',     'Tap to hear any prayer in three languages.',        '5prayers.png',           true],
  ['Word by word',          'Read at the *speed of prayer*',             'A meditative reader that paces every phrase.',      '6speedreader.png',       true],
  ['Day or night',          'Beautiful in *light & dark*',               'Warm parchment by day, soft black by night.',       '7lightmodehome.png',     false],
];

const emphasize = (s) => s.replace(/\*([^*]+)\*/g, '<em>$1</em>');

const css = `
@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,500;0,600;0,700;1,500;1,600&display=swap');
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:1290px;height:2796px;overflow:hidden}
body{
  font-family:'Cormorant Garamond','Baskerville','Hoefler Text',Georgia,serif;
  position:relative;
  background:
    radial-gradient(120% 70% at 12% -8%, rgba(201,162,75,.22), transparent 52%),
    radial-gradient(130% 80% at 100% 112%, rgba(137,84,160,.50), transparent 58%),
    linear-gradient(168deg,#1d1024 0%, #2e1a3b 46%, #190e21 100%);
}
.lightbg{
  background:
    radial-gradient(120% 70% at 12% -8%, rgba(201,162,75,.30), transparent 52%),
    radial-gradient(130% 80% at 100% 112%, rgba(137,84,160,.32), transparent 58%),
    linear-gradient(168deg,#efe7d6 0%, #e7dcc8 50%, #efe9dc 100%);
}
/* grain */
body::after{content:"";position:absolute;inset:0;pointer-events:none;opacity:.05;mix-blend-mode:overlay;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='3'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");}
/* faint cross watermark */
.cross{position:absolute;font-size:1300px;line-height:1;right:-260px;bottom:-260px;
  color:rgba(201,162,75,.055);pointer-events:none;user-select:none;font-weight:600}
.lightbg .cross{color:rgba(90,52,112,.06)}

.wrap{position:relative;z-index:2;height:100%;display:flex;flex-direction:column;padding:150px 0 0}
.cap{padding:0 116px;text-align:center}
.kicker{font-size:31px;letter-spacing:.42em;text-transform:uppercase;font-weight:600;
  color:#E6C66E;display:inline-flex;align-items:center;gap:30px;margin-bottom:34px}
.kicker::before,.kicker::after{content:"";height:1.5px;width:60px;
  background:linear-gradient(90deg,transparent,#C9A24B)}
.kicker::after{background:linear-gradient(90deg,#C9A24B,transparent)}
.lightbg .kicker{color:#9a6b1e}
.lightbg .kicker::before{background:linear-gradient(90deg,transparent,#9a6b1e)}
.lightbg .kicker::after{background:linear-gradient(90deg,#9a6b1e,transparent)}

h1{font-size:104px;line-height:1.0;font-weight:600;letter-spacing:-.01em;color:#fff}
h1 em{font-style:italic;color:#E6C66E}
.lightbg h1{color:#241430}
.lightbg h1 em{color:#7e4fa6}
.sub{font-size:38px;font-style:italic;font-weight:500;color:rgba(242,238,228,.62);margin-top:30px;line-height:1.3}
.lightbg .sub{color:rgba(40,20,55,.6)}

.phonewrap{flex:1;display:flex;justify-content:center;align-items:flex-end;margin-top:64px}
.phone{
  width:1024px;border-radius:108px;padding:26px;
  background:linear-gradient(150deg,#3c3c41,#161618 55%,#2a2a2e);
  box-shadow:0 -10px 0 rgba(255,255,255,.04) inset, 0 60px 120px -30px rgba(0,0,0,.7),
             0 0 0 2px rgba(0,0,0,.5), 0 0 0 4px rgba(201,162,75,.16);
  transform:translateY(70px);
}
.phone img{width:100%;display:block;border-radius:82px}
`;

function html(slide) {
  const [kicker, headline, sub, img, dark] = slide;
  return `<!DOCTYPE html><html><head><meta charset="utf-8"><style>${css}</style></head>
<body class="${dark ? '' : 'lightbg'}">
  <div class="cross">✝</div>
  <div class="wrap">
    <div class="cap">
      <div class="kicker">${kicker}</div>
      <h1>${emphasize(headline)}</h1>
      <div class="sub">${sub}</div>
    </div>
    <div class="phonewrap"><div class="phone"><img src="${img}"></div></div>
  </div>
</body></html>`;
}

const names = ['01-today','02-rosary-listen','03-bible-parallel','04-prayers','05-speed-reader','06-light-dark'];

SLIDES.forEach((slide, i) => {
  const file = join(DIR, `_slide-${names[i]}.html`);
  writeFileSync(file, html(slide));
  const png = join(OUT, `${names[i]}.png`);
  execFileSync(CHROME, [
    '--headless=new', '--disable-gpu', '--hide-scrollbars',
    '--force-device-scale-factor=1',
    '--window-size=1290,2796',
    '--virtual-time-budget=5000',
    '--default-background-color=00000000',
    `--screenshot=${png}`,
    `file://${file}`,
  ], { stdio: 'ignore' });
  console.log('rendered', png);
});
console.log('\nDone →', OUT);
