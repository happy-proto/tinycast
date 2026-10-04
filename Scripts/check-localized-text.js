#!/usr/bin/env node
// A concatenated String selects SwiftUI's verbatim overload instead of a localizable literal.
"use strict";

const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..");
const CATALOG = "Tinycast/Localizable.xcstrings";
const LOCALIZABLE_VIEWS = "Text|Label|Button|Toggle|Picker|Menu|NavigationLink|TextField|SecureField";
const SWIFT_LITERAL = String.raw`"(?:[^"\\]|\\.)*"`;
const CONCATENATED_LITERALS = String.raw`(?:${SWIFT_LITERAL}\s*\+\s*)+${SWIFT_LITERAL}`;
const VERBATIM_TEXT = new Set([
  "AI", "Aa", "GitHub", "Ultra", "Redux", "Bearer …", "npx", "GITHUB_TOKEN=…",
  "https://example.com/mcp", "~/.local/share/mise/shims",
  "-y @modelcontextprotocol/server-filesystem ~/Desktop",
]);

function swiftSources(directory, found = []) {
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) swiftSources(fullPath, found);
    else if (entry.name.endsWith(".swift")) found.push(fullPath);
  }
  return found;
}

function lineNumber(source, offset) {
  return source.slice(0, offset).split("\n").length;
}

function joinedString(expression) {
  return [...expression.matchAll(new RegExp(SWIFT_LITERAL, "g"))]
    .map((match) => JSON.parse(match[0]))
    .join("");
}

const catalog = JSON.parse(fs.readFileSync(path.join(ROOT, CATALOG), "utf8")).strings;
const problems = [];
const implicitPattern = new RegExp(
  String.raw`\b(?:${LOCALIZABLE_VIEWS})\s*\(\s*(${CONCATENATED_LITERALS})`,
  "gs"
);
const explicitPattern = new RegExp(
  String.raw`(?:SettingsLocalization|ExtensionLocalization)\.string\(\s*(${CONCATENATED_LITERALS})\s*\)`,
  "gs"
);
const runtimePattern = new RegExp(
  String.raw`(?:SettingsLocalization|ExtensionLocalization)\.(?:string|format)\s*\(\s*("[^"\\\n]+")`,
  "g"
);
const settingsPattern = new RegExp(
  String.raw`\b(?:Text|Label|Button|Toggle|Picker|Menu|NavigationLink|(?:SettingsLocalization|ExtensionLocalization)\.(?:string|format))\s*\(\s*("[^"\\\n]+")|\b(?:title|subtitle|enableTitle|enableSubtitle|footer):\s*("[^"\\\n]+")|SettingsRowTitle\([^,]+,\s*("[^"\\\n]+")`,
  "g"
);

function checkTranslation(key, relativePath, source, offset) {
  if (!/[A-Za-z]{2}/.test(key)) return;
  if (VERBATIM_TEXT.has(key)) return;
  const unit = catalog[key]?.localizations?.["zh-Hans"]?.stringUnit;
  if (unit?.state !== "translated" || !unit.value) {
    problems.push(
      `${relativePath}:${lineNumber(source, offset)} — missing zh-Hans catalog entry for “${key}”`
    );
  }
}

for (const file of swiftSources(path.join(ROOT, "Tinycast"))) {
  const source = fs.readFileSync(file, "utf8");
  const relativePath = path.relative(ROOT, file);
  if (relativePath.includes("/Settings/") || relativePath.endsWith("/SettingsComponents.swift")) {
    for (const match of source.matchAll(settingsPattern)) {
      const literal = match[1] ?? match[2] ?? match[3];
      if (/^\s*\+/.test(source.slice(match.index + match[0].length))) continue;
      checkTranslation(JSON.parse(literal), relativePath, source, match.index);
    }
  }
  if (/\/(?:CommandID|Fallback|WindowCycle)\.swift$/.test(relativePath)) {
    const names = source.split(/\n    (?:var sfSymbol|static func ordered)/)[0];
    for (const match of names.matchAll(/case [^\n]+:\s*(?:return\s+)?"([^"\\]+)"/g)) {
      checkTranslation(match[1], relativePath, source, match.index);
    }
  }
  if (/\/Dictation(?:Mode|Destination|Language|Model)\.swift$/.test(relativePath)) {
    const labels = relativePath.endsWith("/DictationLanguage.swift")
      ? source
      : [...source.matchAll(/var (?:title|summary|coverage): String \{([^\n]*\}|[\s\S]*?\n    \})/g)]
        .map((match) => match[1]).join("\n");
    for (const match of labels.matchAll(/"[^"\\\n]+"/g)) {
      checkTranslation(JSON.parse(match[0]), relativePath, source, source.indexOf(match[0]));
    }
  }
  for (const match of source.matchAll(runtimePattern)) {
    if (/^\s*\+/.test(source.slice(match.index + match[0].length))) continue;
    checkTranslation(JSON.parse(match[1]), relativePath, source, match.index);
  }
  for (const match of source.matchAll(implicitPattern)) {
    problems.push(
      `${relativePath}:${lineNumber(source, match.index)} — concatenated UI text is not localized`
    );
  }
  for (const match of source.matchAll(explicitPattern)) {
    const key = joinedString(match[1]);
    const unit = catalog[key]?.localizations?.["zh-Hans"]?.stringUnit;
    if (unit?.state !== "translated" || !unit.value) {
      problems.push(
        `${relativePath}:${lineNumber(source, match.index)} — missing zh-Hans catalog entry for “${key}”`
      );
    }
  }
}

if (problems.length > 0) {
  console.error("\n✗ Fixed UI text that bypasses localization:");
  for (const problem of problems) console.error(`  ${problem}`);
  process.exit(1);
}

console.log("✓ localized-text-clean");
