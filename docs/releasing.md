# Releasing the MedTech Platform

Platform releases are driven by two GitHub Actions workflows that must be run **in order**.  
No manual version editing is required — the pipelines handle all version bumping, changelog generation, and tagging.

---

## Prerequisites

Before triggering a release, each component service must have its own GitHub Release published in its own repo (`medtech-vitals-publisher`, `medtech-edge-analytics`, `medtech-clinician-ui`).  
The platform `docker-compose.yml` must reference a real semver tag (e.g. `v1.2.3`) for every service — **not `:latest`**.  
The CD sync workflow (Step 1 below) handles the transition from `:latest` to a pinned version automatically.

---

## Step 1 — Run the CD Sync workflow

**Workflow:** `CD — Sync GHCR Images`  
**File:** [`.github/workflows/cd-sync-images.yml`](../.github/workflows/cd-sync-images.yml)

1. Go to **Actions → CD — Sync GHCR Images → Run workflow**.
2. Leave *Dry run* unchecked (or check it first to preview what would change without opening PRs).
3. Click **Run workflow**.

What it does:
- Queries the GitHub Releases API for each service repo.
- Compares the latest published release tag against what is currently pinned in `docker-compose.yml`.
- For every service that is out of date it opens one PR of the form:

  ```
  chore(cd): bump medtech-<service> → v1.2.3
  ```

  The PR updates the single image line in `docker-compose.yml` and triggers the CI smoke-test suite automatically.

4. Review and **merge each bump PR** once CI is green.
   > There will be one PR per service that has a new release — typically up to three.

After all bump PRs are merged `docker-compose.yml` will look like:

```yaml
image: ghcr.io/chaithubk/medtech-vitals-publisher:v1.2.3  # cd-managed
image: ghcr.io/chaithubk/medtech-edge-analytics:v2.0.1    # cd-managed
image: ghcr.io/chaithubk/medtech-clinician-ui:v1.5.0      # cd-managed
```

---

## Step 2 — Run the Release workflow

**Workflow:** `Release`  
**File:** [`.github/workflows/release.yml`](../.github/workflows/release.yml)

1. Go to **Actions → Release → Run workflow**.
2. Fill in the inputs:

   | Input | Description | Default |
   |---|---|---|
   | `bump_type` | `patch` / `minor` / `major` — follows semver | `patch` |
   | `custom_version` | Override to an exact version e.g. `2.0.0` (optional) | *(empty)* |
   | `prerelease` | Mark the GitHub Release as a pre-release | `false` |

3. Click **Run workflow**.

### What the Release workflow does

| Job | Purpose |
|---|---|
| `validate-components` | Reads `docker-compose.yml`, rejects any service still on `:latest`, and verifies every pinned GHCR image is pullable. Outputs the three component versions for the release notes. |
| `release` | Computes the next semver tag (or uses `custom_version`), generates a categorised changelog from conventional commits, appends a component Bill of Materials and submodule snapshot, creates a Git tag, and publishes a GitHub Release. |

### Version bump rules

- `patch` → `v1.2.3` becomes `v1.2.4`
- `minor` → `v1.2.3` becomes `v1.3.0`
- `major` → `v1.2.3` becomes `v2.0.0`
- `custom_version` → used exactly as specified (must be greater than the previous tag)

The resolved version must always be **strictly greater** than the previous platform tag — the workflow will fail otherwise.

---

## Why the release fails if services are on `:latest`

The `validate-components` job intentionally blocks a release when any service image is unversioned:

```
Error: medtech-vitals-publisher is still pinned to :latest
       — run the cd-sync workflow and merge the bump PR first.
```

This ensures every platform release has a traceable, immutable Bill of Materials. A release with `:latest` images could silently bundle a different binary on every `docker compose pull`.

---

## Release checklist

```
[ ] All three service repos have published GitHub Releases for their latest changes
[ ] CD Sync workflow has been run
[ ] All bump PRs from CD Sync are merged and CI is green on main
[ ] docker-compose.yml has semver tags for all three services (not :latest)
[ ] Release workflow triggered with correct bump_type
[ ] GitHub Release published with correct tag and changelog
```

---

## Hotfix / out-of-band release

If only one service needs a hotfix:

1. Publish a patch release in that service's own repo.
2. Run the CD Sync workflow — it opens a single bump PR for the affected service.
3. Merge the bump PR.
4. Trigger the Release workflow with `bump_type=patch`.

---

## Updating the base image digest (Dockerfile)

The root `Dockerfile` pins `alpine:3.21` by digest for reproducibility. When a new Alpine 3.21 patch is released and you want to adopt it:

```bash
docker pull alpine:3.21
docker inspect alpine:3.21 --format '{{index .RepoDigests 0}}'
# → alpine@sha256:<new-digest>
```

Update `Dockerfile` line 1 with the new digest, commit, and open a PR before the next release.
