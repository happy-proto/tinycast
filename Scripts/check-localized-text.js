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
  String.raw`SettingsLocalization\.string\(\s*(${CONCATENATED_LITERALS})\s*\)`,
  "gs"
);

for (const file of swiftSources(path.join(ROOT, "Tinycast"))) {
  const source = fs.readFileSync(file, "utf8");
  const relativePath = path.relative(ROOT, file);
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
