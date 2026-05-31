# Changelog

## reproducr (development version)

## reproducr 0.1.0

### New features

- [`audit_script()`](https://ndohpenngit.github.io/reproducr/reference/audit_script.md)
  — parse `.R`, `.Rmd`, and `.qmd` files to extract all qualified
  `pkg::fn` calls with version resolution from `renv.lock` or the
  installed library.

- [`risk_score()`](https://ndohpenngit.github.io/reproducr/reference/risk_score.md)
  — three independent risk checks:

  - `"changelog"`: curated database of 26 known breaking changes across
    11 popular packages and base R.
  - `"seed_check"`: flags stochastic functions without a nearby
    [`set.seed()`](https://rdrr.io/r/base/Random.html).
  - `"locale_check"`: flags locale-sensitive operations.

- [`certify()`](https://ndohpenngit.github.io/reproducr/reference/certify.md)
  — hash and store analytical outputs as a signed baseline.

- [`check_drift()`](https://ndohpenngit.github.io/reproducr/reference/check_drift.md)
  — compare current outputs against a stored baseline; reports `"ok"`,
  `"drifted"`, `"missing"`, and `"new"` statuses.

- [`list_certs()`](https://ndohpenngit.github.io/reproducr/reference/list_certs.md)
  — inspect all certifications stored in a project’s `.reproducr.rds`
  file.

- [`repro_report()`](https://ndohpenngit.github.io/reproducr/reference/repro_report.md)
  — render audit reports in three styles (`"minimal"`, `"academic"`,
  `"pharma"`) and three formats (`"text"`, `"md"`, `"html"`).

- [`repro_badge()`](https://ndohpenngit.github.io/reproducr/reference/repro_badge.md)
  — generate a shields.io reproducibility status badge and optionally
  insert it into `README.md`.

### Breaking changes database

Initial coverage: `dplyr`, `tidyr`, `ggplot2`, `readr`, `purrr`,
`stringr`, `lubridate`, `broom`, `data.table`, `lme4`, and base R (R
3.6.0 RNG changes, R 4.0.0
[`hclust()`](https://rdrr.io/r/stats/hclust.html) tie-breaking).
