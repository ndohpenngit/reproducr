#' Check whether breaking-changes database entries are stale
#'
#' @description
#' Compares the `to_version` ceiling of each entry in the breaking-changes
#' database against the current version of that package on CRAN. Entries
#' whose `to_version` is below the current CRAN version may need their
#' ceiling updated to reflect new releases.
#'
#' This function is primarily intended for use by `reproducr` maintainers
#' and contributors. It is also run as a scheduled GitHub Actions workflow
#' on the `reproducr` repository to automatically open issues when staleness
#' is detected.
#'
#' @param packages `character` or `NULL`. Package names to check. If `NULL`
#'   (the default), all packages tracked in the breaking-changes database are
#'   checked.
#' @param verbose `logical(1)`. Print progress messages. Default `TRUE`.
#' @param source `character(1)`. Where to resolve current package versions.
#'   One of:
#'   \describe{
#'     \item{`"cran"`}{Query the CRAN package database via
#'       `utils::available.packages()`. Requires an internet connection.}
#'     \item{`"installed"`}{Use locally installed versions via
#'       `utils::installed.packages()`. Fast and offline, but only reflects
#'       what is installed on the current machine.}
#'   }
#'   Default `"cran"`.
#'
#' @return A `data.frame` of class `c("staleness_report", "data.frame")`
#'   with one row per database entry. Columns:
#'   \describe{
#'     \item{`key`}{The `pkg::fn` key.}
#'     \item{`pkg`}{Package name.}
#'     \item{`fn`}{Function name.}
#'     \item{`to_version`}{The ceiling version currently in the database.}
#'     \item{`current_version`}{The current version on CRAN or installed.}
#'     \item{`status`}{One of `"ok"`, `"stale"`, or `"unknown"`.}
#'     \item{`gap`}{The version difference as a string, e.g. `"1.1.9 -> 1.3.0"`.
#'       `NA` when status is `"unknown"`.}
#'   }
#'   Rows are ordered: stale first, then ok, then unknown.
#'   Printed invisibly when all entries are current.
#'
#' @section Staleness vs requiring an update:
#' A stale entry does not automatically mean the database is wrong. It means
#' the package has released a new version since the ceiling was set. A human
#' must determine whether:
#' \enumerate{
#'   \item The breaking change still applies in the new version (extend ceiling).
#'   \item The new version fixed or reverted the change (lower or remove ceiling).
#'   \item The entry should be closed because the ecosystem has moved on.
#' }
#' See the contributing vignette for guidance on setting `to_version`.
#'
#' @seealso
#' [reproducr::risk_score()] which uses the database at runtime;
#' `vignette("contributing-to-the-database")` for the database schema and
#' version window design principles.
#'
#' @examples
#' \dontrun{
#' # Check all tracked packages against CRAN
#' report <- check_db_staleness()
#' print(report)
#'
#' # Check specific packages only
#' check_db_staleness(packages = c("dplyr", "tidyr"))
#'
#' # Offline check using installed versions
#' check_db_staleness(source = "installed")
#'
#' # Filter to stale entries only
#' report <- check_db_staleness()
#' report[report$status == "stale", ]
#' }
#'
#' @export
check_db_staleness <- function(packages = NULL,
                                verbose  = TRUE,
                                source   = "cran") {

  source <- match.arg(source, c("cran", "installed"))

  # Collect all unique packages tracked in the database
  all_keys <- .list_db_keys()
  all_pkgs <- unique(vapply(
    strsplit(all_keys, "::"),
    `[[`, 1L,
    FUN.VALUE = character(1L)
  ))

  # Filter to requested packages
  if (!is.null(packages)) {
    unknown_pkgs <- setdiff(packages, all_pkgs)
    if (length(unknown_pkgs) > 0L) {
      warning(
        "Package(s) not found in database: ",
        paste(unknown_pkgs, collapse = ", "),
        call. = FALSE
      )
    }
    all_pkgs <- intersect(packages, all_pkgs)
    if (length(all_pkgs) == 0L) {
      stop("No matching packages found in the database.", call. = FALSE)
    }
  }

  # Resolve current versions
  if (verbose) {
    message(sprintf(
      "reproducr: checking %d package(s) against %s...",
      length(all_pkgs), source
    ))
  }

  current_versions <- .resolve_current_versions(all_pkgs, source, verbose)

  # Build results
  results <- list()

  for (key in all_keys) {
    parts <- strsplit(key, "::")[[1L]]
    pkg   <- parts[[1L]]
    fn    <- parts[[2L]]

    # Skip if not in requested packages
    if (!is.null(packages) && !pkg %in% packages) next

    entries <- .get_breaking_changes(key)
    if (is.null(entries)) next

    curr_ver <- current_versions[[pkg]]

    for (entry in entries) {
      # Skip intentionally closed entries — their to_version is deliberately
      # set low (e.g. historical base R changes). Flagging them as stale
      # would be a false positive.
      if (isTRUE(entry$closed)) next

      to_ver  <- entry$to_version
      status  <- .assess_staleness(curr_ver, to_ver)
      gap     <- if (!is.na(curr_ver) && status == "stale") {
        sprintf("%s -> %s", to_ver, curr_ver)
      } else {
        NA_character_
      }

      results[[length(results) + 1L]] <- data.frame(
        key             = key,
        pkg             = pkg,
        fn              = fn,
        to_version      = to_ver,
        current_version = if (is.na(curr_ver)) NA_character_ else curr_ver,
        status          = status,
        gap             = gap,
        stringsAsFactors = FALSE
      )
    }
  }

  if (length(results) == 0L) {
    out <- .empty_staleness_df()
  } else {
    out         <- do.call(rbind, results)
    status_ord  <- c(stale = 1L, ok = 2L, unknown = 3L)
    out$.ord    <- status_ord[out$status]
    out         <- out[order(out$.ord, out$pkg, out$fn), ]
    out$.ord    <- NULL
    row.names(out) <- NULL
  }

  class(out) <- c("staleness_report", "data.frame")

  n_stale   <- sum(out$status == "stale",   na.rm = TRUE)
  n_ok      <- sum(out$status == "ok",      na.rm = TRUE)
  n_unknown <- sum(out$status == "unknown", na.rm = TRUE)

  if (verbose) {
    message(sprintf(
      "reproducr: %d stale, %d ok, %d unknown",
      n_stale, n_ok, n_unknown
    ))
  }

  if (n_stale > 0L) {
    message(
      "\nStale entries (to_version below current release):\n",
      paste(sprintf("  %s  [%s]", out$key[out$status == "stale"],
                    out$gap[out$status == "stale"]),
            collapse = "\n")
    )
  }

  invisible(out)
}

# ---- S3 methods -------------------------------------------------------------

#' @rdname check_db_staleness
#' @param x A `staleness_report` object.
#' @param ... Additional arguments (currently unused).
#' @export
print.staleness_report <- function(x, ...) {
  n_stale   <- sum(x$status == "stale",   na.rm = TRUE)
  n_ok      <- sum(x$status == "ok",      na.rm = TRUE)
  n_unknown <- sum(x$status == "unknown", na.rm = TRUE)

  cat("\n-- reproducr database staleness report --\n\n")
  cat(sprintf("  %-10s %d\n", "STALE:",   n_stale))
  cat(sprintf("  %-10s %d\n", "OK:",      n_ok))
  cat(sprintf("  %-10s %d\n", "UNKNOWN:", n_unknown))
  cat("\n")

  if (n_stale > 0L) {
    stale <- x[x$status == "stale", , drop = FALSE]
    cat("Stale entries:\n\n")
    for (i in seq_len(nrow(stale))) {
      cat(sprintf(
        "  [STALE] %s\n          to_version=%s | current=%s\n\n",
        stale$key[i],
        stale$to_version[i],
        stale$current_version[i]
      ))
    }
    cat("Action: review each entry and update to_version in\n")
    cat("        R/breaking_changes_db.R. See vignette('contributing-to-the-database').\n\n")
  } else {
    cat("  All entries are current.\n\n")
  }

  invisible(x)
}

# ---- internal helpers -------------------------------------------------------

#' Resolve current package versions from CRAN or installed library
#' @noRd
.resolve_current_versions <- function(pkgs, source, verbose) {
  versions <- setNames(
    rep(NA_character_, length(pkgs)),
    pkgs
  )

  if (source == "cran") {
    tryCatch({
      avail <- utils::available.packages(
        repos = getOption("repos", "https://cloud.r-project.org")
      )
      for (pkg in pkgs) {
        if (pkg %in% rownames(avail)) {
          versions[[pkg]] <- avail[pkg, "Version"]
        } else if (pkg %in% c("base", "stats", "utils", "tools", "methods")) {
          # Base R packages — use R version
          versions[[pkg]] <- paste(R.version$major, R.version$minor, sep = ".")
        }
      }
    }, error = function(e) {
      if (verbose) message("reproducr: CRAN query failed, falling back to installed library")
      inst <- utils::installed.packages()[, c("Package", "Version"), drop = FALSE]
      for (pkg in pkgs) {
        if (pkg %in% inst[, "Package"]) {
          versions[[pkg]] <<- inst[inst[, "Package"] == pkg, "Version"]
        }
      }
    })
  } else {
    # installed
    inst <- utils::installed.packages()[, c("Package", "Version"), drop = FALSE]
    for (pkg in pkgs) {
      if (pkg %in% inst[, "Package"]) {
        versions[[pkg]] <- inst[inst[, "Package"] == pkg, "Version"]
      } else if (pkg %in% c("base", "stats", "utils", "tools", "methods")) {
        versions[[pkg]] <- paste(R.version$major, R.version$minor, sep = ".")
      }
    }
  }

  versions
}

#' Assess staleness of a single entry
#' @noRd
.assess_staleness <- function(current_ver, to_ver) {
  if (is.na(current_ver)) return("unknown")
  tryCatch({
    cv <- package_version(as.character(current_ver))
    tv <- package_version(as.character(to_ver))
    if (cv > tv) "stale" else "ok"
  }, error = function(e) "unknown")
}

#' Empty staleness data frame with correct columns
#' @noRd
.empty_staleness_df <- function() {
  data.frame(
    key             = character(0),
    pkg             = character(0),
    fn              = character(0),
    to_version      = character(0),
    current_version = character(0),
    status          = character(0),
    gap             = character(0),
    stringsAsFactors = FALSE
  )
}