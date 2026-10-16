#!/usr/bin/env node
// Fails when plugin text still names a Cursor mechanism that CONTEXT.md rewrites into its Maestri form.
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const root = join(import.meta.dirname, "..", "plugins", "pstack");
const extensions = [".md", ".json", ".sh", ".ts", ".mjs"];

const denylist = [
  [/\.cursor\//, "Cursor config path"],
  [/\.mdc\b|alwaysApply/, "Cursor rule file; use the model sheet"],
  [/\bAskQuestion\b/, "use AskUserQuestion"],
  [/`Task`|\bTask (?:tool|subagent|calls?|spawn|schema|response)\b|\bvia Task\b/, "Cursor subagent tool; use local or canvas dispatch"],
  [/\b(?:run|is)_background\b(?!: true)/, "Cursor background flag"],
  [/generalPurpose/, "Cursor agent type"],
  [/readonly(?::| strips|\/Ask)|\bAsk mode\b/, "Cursor readonly mode; say 'Do not edit files.' in the brief"],
  [/agent-transcripts/, "Cursor transcripts; use Claude Code transcripts or maestri check"],
  [/\bcloud[- ](?:agents?|VMs?|workers?|work|default)\b|cloud_base_branch|Cursor dashboard/, "Cursor cloud agents; use recruits on floors"],
  [/create-skill/, "Cursor built-in; use Claude Code's skill-authoring skill"],
  [/control-(?:ui|cli)/, "cursor-team-kit driver; use the verify skill or maestri portal"],
  [/cursor-team-kit|Thermos plugin/, "these skills ship in this plugin"],
  [/(?<![\w./<>-])pstack\/skills\/|origin\/main:pstack\//, "Lauren's repo path; use <plugin root>/skills/"],
  [/\bgrok-\d|\b(?:claude|gpt|gemini|composer)-[0-9a-z.-]*-(?:max|fast|xhigh|high|medium|low|thinking)\b/, "Cursor model slug; point at the Models section"],
  [/\bCursor\b|cursor\.com/, "Cursor product reference"],
  [/Custom Modes?\b|Agents Window|\/add-plugin/, "Cursor UI"],
  [/(?:^|[\s`(])\/goal\b|\bmcps\//, "Cursor-only mechanism"],
  [/(?:^|[\s`(])\/visualize\b/, "Cursor canvas command; use maestri note"],
];

// Lines that name Cursor only to credit the upstream source.
const allowed = [/github\.com\/cursor\/plugins|`cursor\/plugins`|\(cursor\/plugins\)/, /Lauren Tan/];

function* walk(dir) {
  for (const name of readdirSync(dir)) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) {
      yield* walk(path);
    } else if (extensions.some((extension) => name.endsWith(extension))) {
      yield path;
    }
  }
}

let failures = 0;
for (const path of walk(root)) {
  const lines = readFileSync(path, "utf8").split("\n");
  lines.forEach((line, index) => {
    if (allowed.some((pattern) => pattern.test(line))) {
      return;
    }
    for (const [pattern, hint] of denylist) {
      if (pattern.test(line)) {
        failures += 1;
        console.log(`${relative(root, path)}:${index + 1}: ${hint}\n    ${line.trim().slice(0, 160)}`);
      }
    }
  });
}

if (failures > 0) {
  console.log(`\n${failures} Cursor references left`);
  process.exit(1);
}
console.log("no Cursor references left");
