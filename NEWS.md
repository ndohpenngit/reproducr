# reproducr (development version)

* `check_db_staleness()` — compares `to_version` ceilings in the
  breaking-changes database against current CRAN releases. Returns a tidy
  `staleness_report` data frame with `"ok"`, `"stale"`, or `"unknown"`
  status per entry. A weekly GitHub Actions workflow runs this automatically
  and opens a GitHub issue when stale entries are detected
  (`.github/workflows/db-staleness.yml`).

* Narrowed version windows for base R RNG entries (`stats::rnorm`,
  `stats::rbinom`, `stats::runif`, `stats::sample`) from `to_version = "4.9.9"`
  to `"3.6.9"`. Users on modern R (>= 4.x) were being falsely flagged for
  a 2019 change they are all on the same side of.

* Narrowed version window for `stats::hclust` from `"4.9.9"` to `"4.0.9"`
  for the same reason.

* Added version window design principles to `R/breaking_changes_db.R` and
  expanded `vignette("contributing-to-the-database")` with three rules for
  setting `to_version` and a quick-reference table.

# reproducr 0.1.0

* `audit_script()` — parse `.R`, `.Rmd`, and `.qmd` files to extract all
  qualified `pkg::fn` calls with version resolution from `renv.lock` or the
  installed library.

* `risk_score()` — three independent risk checks: `"changelog"` (curated
  database of known breaking changes), `"seed_check"` (flags stochastic
  functions without a nearby `set.seed()`), and `"locale_check"` (flags
  locale-sensitive operations).

* `certify()` — hash and store analytical outputs as a signed baseline.

* `check_drift()` — compare current outputs against a stored baseline;
  reports `"ok"`, `"drifted"`, `"missing"`, and `"new"` statuses.

* `list_certs()` — inspect all certifications stored in a project's
  `.reproducr.rds` file.

* `repro_report()` — render audit reports in three styles (`"minimal"`,
  `"academic"`, `"pharma"`) and three formats (`"text"`, `"md"`, `"html"`).

* `repro_badge()` — generate a shields.io reproducibility status badge and
  optionally insert it into `README.md`.

* Initial breaking-changes database covering `dplyr`, `tidyr`, `ggplot2`,
  `readr`, `purrr`, `stringr`, `lubridate`, `broom`, `data.table`, `lme4`,
  and base R (R 3.6.0 RNG changes, R 4.0.0 `hclust()` tie-breaking).