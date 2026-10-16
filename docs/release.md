# Builds and distribution

This personal fork is built and installed locally as `Tinycast Dev.app`. It does not publish releases
or deploy the upstream website. See [development.md](development.md) for the local build loop and
[signing.md](signing.md) for the local signing identity.

## Validation CI

[CI](../.github/workflows/ci.yml) runs on pushes to `main`, pull requests targeting `main`, and manual
workflow dispatch. It checks the generated Xcode project, runs the harnesses and lint, enforces model
imports, and builds Debug without signing. The workflow has read-only repository permissions and
needs no release, deployment or notification secrets.

The upstream Release, Website, Triage and Co-authors workflows are removed from this fork. Review
workflow changes when rebasing upstream so they are not restored accidentally. The maintained scope
is recorded in [fork changes](fork-changes/0001-maintenance-and-dev-app.md).

If GitHub shows no run for a pushed commit, check the Actions page for a disabled-fork banner.
The repository permissions API can report Actions enabled while this separate restriction is active.
After enabling Actions, dispatch CI for the current `main` and verify its terminal result.

## Local installation

Run `./Scripts/install-dev-app.sh` from a clean `main`. It builds, signs, installs and starts the Dev
app, then verifies the installed process. See the [Dev App workflow](../.agents/skills/tinycast-fork-maintenance/references/dev-app.md).

Local DMG packaging scripts remain available for development. Official upstream distribution and
release channels are maintained in the [upstream repository](https://github.com/abue-ammar/tinycast).
