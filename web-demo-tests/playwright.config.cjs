const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: '.',
  testMatch: 'smoke.spec.cjs',
  timeout: 45000,
  expect: { timeout: 10000 },
  retries: 1,
  use: {
    ...devices['Desktop Chrome'],
    viewport: { width: 1440, height: 900 },
    baseURL: 'http://127.0.0.1:8765',
    trace: 'retain-on-failure'
  },
  webServer: {
    command: 'python3 -m http.server 8765 --directory docs',
    url: 'http://127.0.0.1:8765',
    reuseExistingServer: !process.env.CI,
    timeout: 30000
  },
  reporter: [['list'], ['html', { outputFolder: 'web-demo-test-report', open: 'never' }]]
});
