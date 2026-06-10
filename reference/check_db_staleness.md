# Check whether breaking-changes database entries are stale

Compares the `to_version` ceiling and `from_version` floor of each entry
in the breaking-changes database against the current version of that
package on CRAN. Two types of staleness are detected:

- **`stale_ceiling`** – the package has released a new version above the
  `to_version` ceiling. The window may need extending.

- **`stale_floor`** – the current CRAN version is so far ahead of
  `from_version` that the window captures users who are already well
  past the breaking-change transition. The entry may need closing or the
  `from_version` floor raising.

This function is primarily intended for use by `reproducr` maintainers
and contributors. It is also run as a scheduled GitHub Actions workflow
on the `reproducr` repository to automatically open issues when
staleness is detected.

## Usage

``` r
check_db_staleness(
  packages = NULL,
  verbose = TRUE,
  source = "cran",
  from_version_major_threshold = 1L
)
```

## Arguments

- packages:

  `character` or `NULL`. Package names to check. If `NULL` (the
  default), all packages tracked in the breaking-changes database are
  checked.

- verbose:

  `logical(1)`. Print progress messages. Default `TRUE`.

- source:

  `character(1)`. Where to resolve current package versions. One of:

  `"cran"`

  :   Query the CRAN package database via
      [`utils::available.packages()`](https://rdrr.io/r/utils/available.packages.html).
      Requires an internet connection.

  `"installed"`

  :   Use locally installed versions via
      [`utils::installed.packages()`](https://rdrr.io/r/utils/installed.packages.html).
      Fast and offline, but only reflects what is installed on the
      current machine.

  Default `"cran"`.

- from_version_major_threshold:

  `integer(1)` or `Inf`. Number of full major versions the current CRAN
  release must be *ahead* of `from_version` before the entry is flagged
  as having a stale floor. Set to `Inf` to disable this check. Default
  `1L`.

## Value

A `data.frame` of class `c("staleness_report", "data.frame")` with one
row per database entry. Columns:

- `key`:

  The `pkg::fn` key.

- `pkg`:

  Package name.

- `fn`:

  Function name.

- `from_version`:

  The floor version currently in the database.

- `to_version`:

  The ceiling version currently in the database.

- `current_version`:

  The current version on CRAN or installed.

- `status`:

  One of `"ok"`, `"stale_ceiling"`, `"stale_floor"`, or `"unknown"`.

- `gap`:

  Description of the version gap. `NA` when status is `"ok"` or
  `"unknown"`.

Rows are ordered: stale_ceiling first, stale_floor second, then ok, then
unknown.

## See also

[`risk_score()`](https://repro-stats.github.io/reproducr/reference/risk_score.md)
which uses the database at runtime;
[`vignette("contributing-to-the-database")`](https://repro-stats.github.io/reproducr/articles/contributing-to-the-database.md)
for the database schema and version window design principles.

## Examples

``` r
if (FALSE) { # \dontrun{
# Check all tracked packages against CRAN
report <- check_db_staleness()
print(report)

# Check specific packages only
check_db_staleness(packages = c("dplyr", "tidyr"))

# Offline check using installed versions
check_db_staleness(source = "installed")

# Filter to stale entries only
report <- check_db_staleness()
report[report$status != "ok", ]
} # }
```
