// Compose intact simulator captures into store artwork. Requires sharp.
const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');

async function main() {
  const root = path.resolve(__dirname, '..');
  const sets = [
    ['iphone', 'ios-captures-restored', 1206, 2622],
    ['ipad', 'ios-captures-restored-ipad', 2064, 2752],
  ];
  const cards = [
    ['01-welcome', 'Tap to play.', 'Keep flying.', 'Simple one-touch controls'],
    ['02-flight', 'Time your taps.', 'Beat your best.', 'Challenge your best score'],
  ];
  for (const [device, input, width, height] of sets) {
    const out = path.join(root, 'deploy/ios-store-restored', device);
    fs.mkdirSync(out, { recursive: true });
    for (const [name, line1, line2, caption] of cards) {
      const capture = path.join(root, 'deploy', input, `${name}.png`);
      const meta = await sharp(capture).metadata();
      const top = height * 0.29;
      const maxH = height * 0.66;
      const scale = Math.min(width * 0.84 / meta.width, maxH / meta.height);
      const w = Math.round(meta.width * scale), h = Math.round(meta.height * scale);
      const x = Math.round((width - w) / 2), y = Math.round(top);
      const font = Math.round(width * 0.069);
      const data = fs.readFileSync(capture).toString('base64');
      const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">
        <rect width="100%" height="100%" fill="#6FB0E6"/>
        <path d="M0 ${height*.7} Q${width*.6} ${height*.4} ${width} ${height*.65}" fill="none" stroke="#5FA0D6" stroke-width="${width*.15}"/>
        <text x="${width*.08}" y="${height*.055}" fill="#FFFFFF" font-family="Helvetica,Arial,sans-serif" font-size="${width*.027}" font-weight="700" letter-spacing="8">FLUP FUN</text>
        <text x="${width*.08}" y="${height*.115}" fill="white" font-family="Helvetica,Arial,sans-serif" font-size="${font}" font-weight="700">${line1}</text>
        <text x="${width*.08}" y="${height*.115+font*1.12}" fill="#FFFFFF" font-family="Helvetica,Arial,sans-serif" font-size="${font}" font-weight="700">${line2}</text>
        <text x="${width*.08}" y="${height*.245}" fill="#153A50" font-family="Helvetica,Arial,sans-serif" font-size="${width*.027}">${caption}</text>
        <rect x="${x-8}" y="${y-8}" width="${w+16}" height="${h+16}" rx="12" fill="#967265"/>
        <image x="${x}" y="${y}" width="${w}" height="${h}" href="data:image/png;base64,${data}"/>
        <text x="${width*.08}" y="${height*.985}" fill="#153A50" font-family="Helvetica,Arial,sans-serif" font-size="${width*.018}">Actual ${device === 'ipad' ? 'iPad' : 'iPhone'} gameplay</text>
      </svg>`;
      fs.writeFileSync(path.join(out, `${name}.svg`), svg);
      await sharp(Buffer.from(svg)).removeAlpha().png().toFile(path.join(out, `${name}.png`));
    }
  }
}
main().catch(e => { console.error(e); process.exitCode = 1; });
