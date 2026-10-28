// Generates the Arnav Chat brand assets (SVG + PNG renders).
// Usage (from repo root):
//   npm --prefix tool/brand install && node tool/brand/generate.mjs
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Resvg } from '@resvg/resvg-js';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const out = path.join(root, 'assets/brand');
fs.mkdirSync(out, { recursive: true });

// Superellipse (n = 5) squircle path centred in a size x size box.
function squircle(size, n = 5, steps = 240) {
  const r = size / 2;
  const pts = [];
  for (let i = 0; i < steps; i++) {
    const t = (i / steps) * Math.PI * 2;
    const c = Math.cos(t), s = Math.sin(t);
    const x = r + r * Math.sign(c) * Math.abs(c) ** (2 / n);
    const y = r + r * Math.sign(s) * Math.abs(s) ** (2 / n);
    pts.push(`${x.toFixed(2)} ${y.toFixed(2)}`);
  }
  return `M ${pts.join(' L ')} Z`;
}

const gradientDefs = `
  <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#0D1A4A"/>
    <stop offset="0.55" stop-color="#2350E6"/>
    <stop offset="1" stop-color="#27C1D9"/>
  </linearGradient>
  <radialGradient id="shine" cx="0.28" cy="0.18" r="0.75">
    <stop offset="0" stop-color="#9FD8FF" stop-opacity="0.16"/>
    <stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/>
  </radialGradient>`;

// The mark: a speech bubble with an "A" cut out; the crossbar is a chat dot.
const markMask = `
  <mask id="aCut" maskUnits="userSpaceOnUse" x="0" y="0" width="1024" height="1024">
    <rect width="1024" height="1024" fill="#fff"/>
    <path d="M 400 650 L 512 360 L 624 650" fill="none" stroke="#000" stroke-width="74"
          stroke-linecap="round" stroke-linejoin="round"/>
    <circle cx="512" cy="574" r="29" fill="#000"/>
  </mask>`;
const markShape = (fill) => `
  <g mask="url(#aCut)" fill="${fill}">
    <circle cx="512" cy="488" r="318"/>
    <path d="M 232 560 C 230 700 232 800 176 852 C 278 858 362 828 440 768 Z"/>
  </g>`;

const svg = (size, body, defs = '') =>
  `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 1024 1024">` +
  `<defs>${gradientDefs}${markMask}${defs}</defs>${body}</svg>`;

// Mark scaled around the centre (for adaptive icon safe zones).
const scaled = (s, inner) => `<g transform="translate(512 512) scale(${s}) translate(-512 -505)">${inner}</g>`;

const sq = squircle(1024);
const logo = svg(1024, `
  <path d="${sq}" fill="url(#bg)"/>
  <path d="${sq}" fill="url(#shine)"/>
  <path d="${sq}" fill="none" stroke="#FFFFFF" stroke-opacity="0.14" stroke-width="4"/>
  ${scaled(0.78, markShape('#FFFFFF'))}`);

const markOnly = svg(1024, markShape('#FFFFFF'));
const fg = svg(1024, scaled(0.62, markShape('#FFFFFF')));
const bg = svg(1024, `<rect width="1024" height="1024" fill="url(#bg)"/><rect width="1024" height="1024" fill="url(#shine)"/>`);
// Android 12 splash: icon content must sit inside the central 2/3 circle.
const splash12 = svg(1024, `
  <circle cx="512" cy="512" r="341" fill="url(#bg)"/>
  ${scaled(0.5, markShape('#FFFFFF'))}`);

const files = {
  'logo.svg': logo,
  'logo_mark.svg': markOnly,
  'icon_foreground.svg': fg,
  'icon_background.svg': bg,
};
for (const [name, content] of Object.entries(files)) fs.writeFileSync(path.join(out, name), content);

function png(name, content, width) {
  const r = new Resvg(content, { fitTo: { mode: 'width', value: width } });
  fs.writeFileSync(path.join(out, name), r.render().asPng());
}
png('icon_1024.png', logo, 1024);
png('icon_foreground.png', fg, 1024);
png('icon_background.png', bg, 1024);
png('icon_monochrome.png', fg, 1024);
png('splash_logo.png', logo, 576);
png('splash_android12.png', splash12, 1152);
png('logo_48.png', logo, 48);

// Android status-bar notification icon (white silhouette, transparent).
const res = path.join(root, 'android/app/src/main/res');
const notif = svg(1024, scaled(0.92, markShape('#FFFFFF')));
for (const [dpi, px] of [['mdpi', 24], ['hdpi', 36], ['xhdpi', 48], ['xxhdpi', 72], ['xxxhdpi', 96]]) {
  const dir = path.join(res, `drawable-${dpi}`);
  fs.mkdirSync(dir, { recursive: true });
  const r = new Resvg(notif, { fitTo: { mode: 'width', value: px } });
  fs.writeFileSync(path.join(dir, 'ic_notification.png'), r.render().asPng());
}
console.log('brand assets written to', out);
