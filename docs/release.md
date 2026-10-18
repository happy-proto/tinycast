# Builds and distribution

This personal fork is built locally as `Tinycast Dev.app`. It does not publish releases or deploy a
website. See [development.md](development.md) for the local build loop and [signing.md](signing.md)
for the local signing identity.

## Validation CI

[CI](../.github/workflows/ci.yml) runs on pushes to `main`, pull requests targeting `main`, and manual
workflow dispatch. It checks the generated Xcode project, runs the harnesses and lint, enforces model
imports, and builds Debug without signing. The workflow has read-only repository permissions and
needs no release, deployment, mirror or notification secrets.

Only validation workflows belong in this fork. Review workflow changes when rebasing upstream.
The maintained scope is recorded in [fork changes](fork-changes/0006-validation-ci.md).

If GitHub shows no run for a pushed commit, check the Actions page for a disabled-fork banner.
The repository permissions API can report Actions enabled while this separate restriction is active.
After enabling Actions, dispatch CI for the current `main` and verify its terminal result.

## Local installation

Run `./Scripts/install-dev-app.sh` from a clean `main`. It builds, signs, installs and starts the Dev
app, then verifies the installed process. See the [Dev App workflow](../.agents/skills/tinycast-fork-maintenance/references/dev-app.md)
and [installation scope](fork-changes/0007-dev-app-installation.md).

Local DMG packaging scripts remain available for development. Official distribution and release
channels are maintained in the [upstream repository](https://github.com/abue-ammar/tinycast).
