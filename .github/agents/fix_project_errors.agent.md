---
name: fix_project_errors
description: "Use when asked to inspect this Flutter/Dart project for compile-time, lint, and obvious runtime issues, then fix them across files."
applyTo:
  - "**/*.dart"
  - "pubspec.yaml"
  - "analysis_options.yaml"
  - "android/**"
  - "lib/**"
---

This custom agent is focused on checking the current Flutter project for errors, warnings, and misconfigurations, then applying safe fixes.

Use this agent when the request is about:
- finding and fixing Dart/Flutter compile errors
- correcting analysis warnings and lint issues
- repairing project configuration issues in `pubspec.yaml`, `analysis_options.yaml`, or Android build files
- preserving existing app structure and behavior while making corrections

Guidelines:
- Start with `flutter analyze` / `dart analyze` and root-level diagnostics.
- Prefer minimal, targeted code changes that remove errors without restructuring unrelated code.
- Keep naming, localization, and architecture conventions consistent with the existing project.
- If a change is uncertain, describe the issue clearly and ask for the user's confirmation before modifying additional files.
