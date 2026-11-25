const { test, expect } = require('@playwright/test');

test('matches demo identity and renders dashboard', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: /Demo User/ })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Dashboard' })).toBeVisible();
  await expect(page.getByText('FOCUS TIMER').first()).toBeVisible();
  await expect(page.getByText('QUICK LAUNCH')).toBeVisible();
  await page.screenshot({ path: 'launchdesk-demo-preview.png', fullPage: true });
});

test('tasks survive a browser reload', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: 'Tasks' }).click();
  await page.getByRole('button', { name: '+ Add Task' }).click();
  await page.getByLabel('Task', { exact: true }).fill('Check local storage');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByText('Check local storage')).toBeVisible();
  await page.reload();
  await page.getByRole('button', { name: 'Tasks' }).click();
  await expect(page.getByText('Check local storage')).toBeVisible();
  await page.locator('[data-check-task]').check();
  await page.reload();
  await page.getByRole('button', { name: 'Tasks' }).click();
  await expect(page.locator('[data-check-task]')).toBeChecked();
});

test('settings persist and keep visitor as Demo User', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: 'Settings' }).click();
  await page.locator('[data-setting="theme"]').selectOption('light');
  await page.locator('[data-setting="compact"]').check();
  await page.reload();
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'light');
  await expect(page.locator('html')).toHaveAttribute('data-compact', 'true');
  await expect(page.getByText('Demo User').first()).toBeVisible();
});

test('notes, links and habits can be created', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: 'Notes' }).click();
  await page.getByRole('button', { name: '+ New Note' }).click();
  await page.getByLabel('Title').fill('Demo note');
  await page.getByLabel('Content').fill('This is saved locally.');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByText('Demo note')).toBeVisible();
  await page.getByRole('button', { name: 'Habits' }).click();
  await page.getByRole('button', { name: '+ Add Habit' }).click();
  await page.getByLabel('Habit name').fill('Learn programming');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByText('Learn programming')).toBeVisible();
  await page.getByRole('button', { name: 'Apps' }).click();
  await page.getByRole('button', { name: '+ Add Shortcut' }).click();
  await page.getByLabel('Shortcut name').fill('Example');
  await page.getByLabel('Website address (https://)').fill('https://example.com/');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByText('Example')).toBeVisible();
});

test('no browser demo account login or native EXE launch promise', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: 'Apps' }).click();
  await expect(page.getByText(/Browsers cannot open local Windows/)).toBeVisible();
  await page.getByRole('button', { name: 'ChatGPT' }).click();
  await expect(page.getByRole('link', { name: /Open ChatGPT/ })).toHaveAttribute('href', 'https://chatgpt.com/');
});
