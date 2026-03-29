# Contributing to findmbr

Thanks for your interest in contributing to **findmbr** (IBM i source-member search utility)!

This document describes the workflow and a few rules to keep the project maintainable.

## Ways to contribute
- Report bugs / request features via GitHub Issues
- Improve documentation (README, examples, usage notes)
- Submit code changes via Pull Requests (PRs)

## Before you start
- Please search existing Issues/PRs to avoid duplicates.
- For **large changes** (new features, behavioral changes, refactors), open an Issue first to discuss the approach.

## Development workflow (recommended)
1. Fork the repository
2. Create a feature branch from the default branch:
   - `git checkout -b feature/<short-description>`
   - or `fix/<short-description>`
3. Make changes with small, focused commits
4. Open a Pull Request to the default branch

## Pull Request guidelines
A good PR:
- Explains **what** changed and **why**
- Includes steps to **test/verify** the change
- Keeps unrelated changes out (no drive-by reformatting)

When opening a PR, please include:
- **Summary** of the change
- **Motivation / context**
- **How to test**
- Any IBM i / environment notes (version, CCSID, shell used), if relevant

## Coding / style guidelines
This repository contains IBM i sources (RPGLE) and small helper scripts.

Please follow these guidelines:
- Prefer minimal, readable changes over broad rewrites.
- Keep formatting consistent with the surrounding code.
- Avoid committing secrets (passwords, tokens, hostnames that should not be public).
- If your change affects user behavior or CLI output, update the README accordingly.

### Line endings / text encoding
IBM i environments can be sensitive to encoding and line endings.
- Prefer text files with consistent line endings.
- If your change touches source members intended for IBM i, mention any encoding assumptions in the PR.

## Testing
There is currently no mandatory automated test suite.

**Expected verification** (pick what applies and describe it in your PR):
- Run the tool against sample source files / members
- Confirm the search output matches expectations (including edge cases)
- Verify scripts still run in your target shell environment

If you add a test or a simple reproducible verification script, that is very welcome.

## Issue reporting guidelines
When reporting a bug, please include:
- What you expected to happen vs what actually happened
- Command(s) you ran and the output (redact sensitive data)
- Your environment details:
  - IBM i version (e.g., `7.x`) (if applicable)
  - Shell (QShell / PASE bash, etc.)
  - Locale/CCSID notes if you suspect encoding issues

## Licensing
By contributing, you agree that your contributions will be licensed under the **MIT License** (see `LICENSE`).

## Code of Conduct
Be respectful and constructive. Harassment or abusive behavior is not tolerated.

## Contact / maintainers
Maintainer: @benetti-marco