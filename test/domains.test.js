const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

// domains.js reads L7_DIR at module-load time. Point it at a throwaway
// directory *before* requiring — never touch the real ~/.l7.
const FIXTURE_DIR = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-domains-test-'));
process.env.L7_DIR = FIXTURE_DIR;

const domains = require('../lib/domains');

const FOLDERS = ['morph', 'work', 'salt', 'vault'];

test('suggestDomain never grants a domain from a 12D coordinate (ADR 0001)', () => {
  assert.equal(domains.suggestDomain([9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9]), null);
});

test('requiring domains.js with L7_DIR in a temp dir does not create morph/work/salt/vault until write()', () => {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'l7-domains-require-'));
  const domainsPath = require.resolve('../lib/domains');
  const r = spawnSync(
    process.execPath,
    [
      '-e',
      `
        process.env.L7_DIR = ${JSON.stringify(tmp)};
        const fs = require('fs');
        const path = require('path');
        const folders = ${JSON.stringify(FOLDERS)};
        require(${JSON.stringify(domainsPath)});
        const createdOnRequire = folders.filter((d) => fs.existsSync(path.join(${JSON.stringify(tmp)}, d)));
        if (createdOnRequire.length) {
          process.stderr.write('folders after require: ' + createdOnRequire.join(',') + '\\n');
          process.exit(2);
        }
        const domains = require(${JSON.stringify(domainsPath)});
        domains.write('work', 'note.json', { text: 'hello' });
        if (!fs.existsSync(path.join(${JSON.stringify(tmp)}, 'work'))) {
          process.stderr.write('write() did not create work\\n');
          process.exit(3);
        }
        const extras = ['morph', 'salt', 'vault'].filter((d) => fs.existsSync(path.join(${JSON.stringify(tmp)}, d)));
        if (extras.length) {
          process.stderr.write('write(work) also created: ' + extras.join(',') + '\\n');
          process.exit(4);
        }
      `,
    ],
    { encoding: 'utf8' },
  );
  assert.equal(r.status, 0, r.stderr + r.stdout);
  fs.rmSync(tmp, { recursive: true, force: true });
});

test('write() is the first path that creates a domain folder in this process', () => {
  for (const d of FOLDERS) {
    assert.equal(
      fs.existsSync(path.join(FIXTURE_DIR, d)),
      false,
      `${d} must not exist before write()`,
    );
  }
  domains.write('work', 'note.json', { text: 'hello' });
  assert.equal(fs.existsSync(path.join(FIXTURE_DIR, 'work')), true);
  assert.equal(fs.existsSync(path.join(FIXTURE_DIR, 'morph')), false);
  assert.equal(fs.existsSync(path.join(FIXTURE_DIR, 'salt')), false);
  assert.equal(fs.existsSync(path.join(FIXTURE_DIR, 'vault')), false);
});

test.after(() => {
  fs.rmSync(FIXTURE_DIR, { recursive: true, force: true });
});
