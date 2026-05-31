#' reproducr: Behavioural Reproducibility Auditing for R Projects
#'
#' @description
#' You finish an analysis. The code runs. The numbers look right. But are
#' they stable?
#'
#' `reproducr` makes behavioural reproducibility risks visible and trackable.
#' It scans your scripts for known silent breaking changes, flags stochastic
#' calls missing `set.seed()`, certifies analytical outputs as baselines, and
#' detects numerical drift across runs — before it reaches a journal, a
#' regulator, or a collaborator.
#'
#' @section Workflow:
#'
#' **Tier 1 — Scan & score**
#'
#' ```r
#' report <- audit_script("analysis.R")
#' risks  <- risk_score(report)
#' print(risks)
#' ```
#'
#' **Tier 2 — Baseline & drift**
#'
#' ```r
#' model <- lm(mpg ~ wt, data = mtcars)
#' certify(list(coefs = coef(model)), tag = "submission-v1")
#'
#' # After any environment change:
#' check_drift(list(coefs = coef(model)), against = "submission-v1")
#' ```
#'
#' **Tier 3 — Report & export**
#'
#' ```r
#' repro_report(report, risks, format = "html", style = "pharma")
#' repro_badge(report, risks, output = "README")
#' ```
#'
#' @section Key functions:
#'
#' | Function | Purpose |
#' |---|---|
#' | [reproducr::audit_script()] | Parse a script and extract all `pkg::fn` calls |
#' | [reproducr::risk_score()] | Check calls against the breaking-changes database |
#' | [reproducr::certify()] | Hash and store analytical outputs as a baseline |
#' | [reproducr::check_drift()] | Compare current outputs against a stored baseline |
#' | [reproducr::repro_report()] | Render a human-readable audit report |
#' | [reproducr::repro_badge()] | Generate a reproducibility status badge |
#' | [reproducr::list_certs()] | List all certifications in a `.reproducr` file |
#'
#' @section The breaking-changes database:
#'
#' The internal database covers known silent breaking changes in:
#' `dplyr`, `tidyr`, `ggplot2`, `readr`, `purrr`, `stringr`, `broom`,
#' `data.table`, `lme4`, `lubridate`, and base R. Community contributions
#' to expand the database are very welcome — see the contributing vignette.
#'
#' @aliases reproducr-package
"_PACKAGE"
