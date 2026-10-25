import { chromium } from "playwright";
import fs from "node:fs/promises";
import path from "node:path";

const url = process.env.PLAYTEST_URL || process.argv[2] || "http://localhost:4173";
const screenshotPath = path.resolve(
  process.env.PLAYTEST_SCREENSHOT ||
    path.join("docs", "patch-notes", "latest-screen.png"),
);
const requiredStateKeys = [
  "fps",
  "scene",
  "score",
  "playerHp",
  "enemies",
  "particles",
  "upgrades",
];
const consoleErrors = [];
const pageErrors = [];
let browser;
let page;
let state;
let hookError;
const startedAt = Date.now();

function recordConsole(message) {
  if (message.type() === "error") {
    consoleErrors.push(message.text());
  }
}

function recordPageError(error) {
  pageErrors.push(error instanceof Error ? error.message : String(error));
}

function missingStateKeys(value) {
  if (!value || typeof value !== "object") {
    return requiredStateKeys;
  }
  return requiredStateKeys.filter((key) => !(key in value));
}

async function captureScreenshot() {
  if (!page) {
    return;
  }
  await fs.mkdir(path.dirname(screenshotPath), { recursive: true });
  await page.screenshot({ path: screenshotPath, fullPage: true });
}

try {
  browser = await chromium.launch({ headless: true });
  page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  page.on("console", recordConsole);
  page.on("pageerror", recordPageError);

  await page.goto(url, { waitUntil: "networkidle", timeout: 30_000 });
  await page.waitForFunction(
    () =>
      typeof window.__AUTOPLAY__ === "function" &&
      window.__GAME_STATE__ !== undefined,
    undefined,
    { timeout: 15_000 },
  );

  await page.evaluate(() => window.__AUTOPLAY__(true));
  const inputUntil = Date.now() + 8_000;
  let inputCount = 0;
  while (Date.now() < inputUntil) {
    await page.keyboard.press(inputCount % 2 === 0 ? "ArrowRight" : "ArrowLeft");
    await page.keyboard.press(inputCount % 3 === 0 ? "Space" : "ArrowUp");
    await page.mouse.move(640 + (inputCount % 5) * 24, 450);
    inputCount += 1;
    await page.waitForTimeout(250);
  }

  state = await page.evaluate(() => window.__GAME_STATE__);
  const missingKeys = missingStateKeys(state);
  if (missingKeys.length > 0) {
    throw new Error(`__GAME_STATE__ is missing: ${missingKeys.join(", ")}`);
  }
  if (consoleErrors.length > 0 || pageErrors.length > 0) {
    throw new Error("The page reported console or page errors.");
  }
} catch (error) {
  hookError = error instanceof Error ? error.message : String(error);
} finally {
  try {
    await captureScreenshot();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    hookError = hookError ? `${hookError}; screenshot: ${message}` : `screenshot: ${message}`;
  }
  if (browser) {
    await browser.close();
  }
}

const result = {
  url,
  durationMs: Date.now() - startedAt,
  screenshot: screenshotPath,
  state,
  consoleErrors,
  pageErrors,
  error: hookError,
};
console.log(JSON.stringify(result, null, 2));

if (hookError || consoleErrors.length > 0 || pageErrors.length > 0) {
  process.exitCode = 1;
}
