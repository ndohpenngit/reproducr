# reproducr: Computational Reproducibility Auditing for R Projects

`reproducr` audits R scripts for reproducibility risk beyond what
[renv](https://rstudio.github.io/renv/) provides. While `renv` locks
package versions, it cannot tell you:

- Whether a function's *behaviour* changed silently between versions

- Whether stochastic calls lack a
  [`set.seed()`](https://rdrr.io/r/base/Random.html)

- Whether results have numerically drifted since your last analysis

- Whether your code is locale-sensitive

`reproducr` fills those gaps.

## Workflow

**Tier 1 — Scan & score**

    report <- audit_script("analysis.R")
    risks  <- risk_score(report)
    print(risks)

**Tier 2 — Baseline & drift**

    model <- lm(mpg ~ wt, data = mtcars)
    certify(list(coefs = coef(model)), tag = "submission-v1")

    # Later, after a package upgrade:
    check_drift(list(coefs = coef(model)), against = "submission-v1")

**Tier 3 — Report & export**

    repro_report(report, risks, format = "html", style = "pharma")
    repro_badge(report, risks, output = "README")

## Key functions

|  |  |
|----|----|
| Function | Purpose |
| [`audit_script()`](https://ndohpenngit.github.io/reproducr/reference/audit_script.md) | Parse a script and extract all `pkg::fn` calls |
| [`risk_score()`](https://ndohpenngit.github.io/reproducr/reference/risk_score.md) | Check calls against the breaking-changes database |
| [`certify()`](https://ndohpenngit.github.io/reproducr/reference/certify.md) | Hash and store analytical outputs as a baseline |
| [`check_drift()`](https://ndohpenngit.github.io/reproducr/reference/check_drift.md) | Compare current outputs against a stored baseline |
| [`repro_report()`](https://ndohpenngit.github.io/reproducr/reference/repro_report.md) | Render a human-readable audit report |
| [`repro_badge()`](https://ndohpenngit.github.io/reproducr/reference/repro_badge.md) | Generate a reproducibility status badge |
| [`list_certs()`](https://ndohpenngit.github.io/reproducr/reference/list_certs.md) | List all certifications in a `.reproducr` file |

## Relationship to renv

`reproducr` and `renv` are complementary tools, not alternatives. Use
`renv` to freeze package versions. Use `reproducr` to verify that
freezing is actually sufficient — i.e. that no silent behavioural
changes, missing seeds, or locale dependencies threaten your results.

## The breaking-changes database

The internal database currently covers known breaking changes in:
`dplyr`, `tidyr`, `ggplot2`, `readr`, `purrr`, `stringr`, `broom`,
`data.table`, `lme4`, `lubridate`, and base R (RNG changes in R 3.6.0).
Community contributions to expand the database are very welcome — see
the contributing guide on GitHub.

## See also

Useful links:

- <https://github.com/ndohpenngit/reproducr>

- Report bugs at <https://github.com/ndohpenngit/reproducr/issues>

## Author

**Maintainer**: Ndoh Penn <ndohpenn9@gmail.com>
([ORCID](https://orcid.org/0009-0003-9054-465X))
