// capture-screenshots.mjs
// Walks the live Qorven web UI and captures screenshots for every doc page.
// Assumes the gateway is on :4200 and the web app is on :3000 on this box.

import puppeteer from '/home/ec2-user/qorven-mono/web/node_modules/puppeteer/lib/esm/puppeteer/puppeteer.js';
import { writeFile } from 'node:fs/promises';
import path from 'node:path';

const OUT_DIR = '/home/ec2-user/qorven-docs/images/screenshots';
const TOKEN = '011324ca295a14b5ab74044d2898c628';
const WEB = 'http://localhost:3000';

const targets = [
  { name: 'login',            path: '/login',                  auth: false },
  { name: 'dashboard',        path: '/dashboard',              auth: true  },
  { name: 'qors-list',        path: '/qors',                   auth: true  },
  { name: 'rooms',            path: '/rooms',                  auth: true  },
  { name: 'memories',         path: '/memories',               auth: true  },
  { name: 'models-hub',       path: '/models-hub',             auth: true  },
  { name: 'connectors',       path: '/connectors',             auth: true  },
  { name: 'code-editor',      path: '/code',                   auth: true  },
  { name: 'drive',            path: '/drive',                  auth: true  },
  { name: 'mail',             path: '/mail',                   auth: true  },
  { name: 'schedule',         path: '/schedule',               auth: true  },
  { name: 'calendar',         path: '/calendar',               auth: true  },
  { name: 'marketplace',      path: '/marketplace',            auth: true  },
  { name: 'audit',            path: '/audit',                  auth: true  },
  { name: 'knowledge-graph',  path: '/knowledge-graph',        auth: true  },
  { name: 'voice',            path: '/voice',                  auth: true  },
  { name: 'terminal',         path: '/terminal',               auth: true  },
  { name: 'settings',         path: '/settings',               auth: true  },
  { name: 'provider-keys',    path: '/provider-keys',          auth: true  },
  { name: 'channels-list',    path: '/channels',               auth: true  },
  { name: 'workflows',        path: '/workflows',              auth: true  },
  { name: 'cron',             path: '/cron',                   auth: true  },
  { name: 'tasks',            path: '/tasks',                  auth: true  },
  { name: 'teams',            path: '/teams',                  auth: true  },
  { name: 'skills',           path: '/skills',                 auth: true  },
  { name: 'social',           path: '/social',                 auth: true  },
  { name: 'usage',            path: '/usage',                  auth: true  },
  { name: 'analytics',        path: '/analytics',              auth: true  },
  { name: 'approvals',        path: '/approvals',              auth: true  },
  { name: 'pipeline',         path: '/pipeline',               auth: true  },
  { name: 'supervisor',       path: '/supervisor',             auth: true  },
  { name: 'research',         path: '/research',               auth: true  },
  { name: 'sandbox',          path: '/sandbox',                auth: true  },
];

const browser = await puppeteer.launch({
  executablePath: '/home/ec2-user/.cache/ms-playwright/chromium-1208/chrome-linux/chrome',
  headless: 'new',
  args: ['--no-sandbox', '--disable-setuid-sandbox'],
});
const page = await browser.newPage();
await page.setViewport({ width: 1440, height: 900, deviceScaleFactor: 1 });

// Seed the auth token into localStorage so authenticated pages load.
await page.goto(WEB + '/login', { waitUntil: 'domcontentloaded', timeout: 30000 });
await page.evaluate((t) => { localStorage.setItem('qorven_token', t); }, TOKEN);

for (const t of targets) {
  try {
    await page.goto(WEB + t.path, { waitUntil: 'networkidle2', timeout: 45000 });
    // Let animations settle and data fetches finish.
    await new Promise((r) => setTimeout(r, 2000));
    const out = path.join(OUT_DIR, `${t.name}.png`);
    await page.screenshot({ path: out, fullPage: false });
    console.log(`✓ ${t.name} → ${out}`);
  } catch (e) {
    console.error(`✗ ${t.name}: ${e.message}`);
  }
}

await browser.close();
console.log('done');
