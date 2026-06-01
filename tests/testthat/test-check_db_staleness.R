test_that("check_db_staleness() returns a staleness_report data frame", {
  result <- check_db_staleness(source = "installed", verbose = FALSE)

  expect_s3_class(result, "data.frame")
  expect_s3_class(result, "staleness_report")
  expect_true(all(c("key", "pkg", "fn", "to_version",
                    "current_version", "status", "gap")
                  %in% names(result)))
})

test_that("check_db_staleness() status column only contains valid values", {
  result <- check_db_staleness(source = "installed", verbose = FALSE)
  expect_true(all(result$status %in% c("ok", "stale", "unknown")))
})

test_that("check_db_staleness() key column matches pkg::fn format", {
  result <- check_db_staleness(source = "installed", verbose = FALSE)
  expect_true(all(grepl("^[a-zA-Z][a-zA-Z0-9.]*::[a-zA-Z][a-zA-Z0-9._]*$",
                         result$key, perl = TRUE)))
})

test_that("check_db_staleness() pkg and fn columns are consistent with key", {
  result <- check_db_staleness(source = "installed", verbose = FALSE)
  reconstructed <- paste0(result$pkg, "::", result$fn)
  expect_equal(reconstructed, result$key)
})

test_that("check_db_staleness() filters to requested packages", {
  result <- check_db_staleness(
    packages = "dplyr",
    source   = "installed",
    verbose  = FALSE
  )
  expect_true(all(result$pkg == "dplyr"))
})

test_that("check_db_staleness() warns on unknown package name", {
  expect_warning(
    check_db_staleness(
      packages = c("dplyr", "not_a_real_package"),
      source   = "installed",
      verbose  = FALSE
    ),
    "not found in database"
  )
})

test_that("check_db_staleness() errors when no matching packages found", {
  expect_error(
    check_db_staleness(
      packages = "definitely_not_a_package",
      source   = "installed",
      verbose  = FALSE
    ),
    "No matching packages"
  )
})

test_that("check_db_staleness() gap column is NA for non-stale entries", {
  result <- check_db_staleness(source = "installed", verbose = FALSE)
  ok_rows <- result[result$status == "ok", ]
  if (nrow(ok_rows) > 0L) {
    expect_true(all(is.na(ok_rows$gap)))
  }
})

test_that("check_db_staleness() gap column is non-NA for stale entries", {
  result <- check_db_staleness(source = "installed", verbose = FALSE)
  stale_rows <- result[result$status == "stale", ]
  if (nrow(stale_rows) > 0L) {
    expect_true(all(!is.na(stale_rows$gap)))
    expect_true(all(grepl("->", stale_rows$gap, fixed = TRUE)))
  }
})

test_that("check_db_staleness() returns stale entries first", {
  result <- check_db_staleness(source = "installed", verbose = FALSE)
  if (nrow(result) > 1L) {
    status_int <- c(stale = 1L, ok = 2L, unknown = 3L)[result$status]
    expect_true(all(diff(status_int) >= 0L))
  }
})

test_that("check_db_staleness() returns invisibly", {
  ret <- withVisible(
    check_db_staleness(source = "installed", verbose = FALSE)
  )
  expect_false(ret$visible)
})

test_that("print.staleness_report() produces expected output", {
  result <- check_db_staleness(source = "installed", verbose = FALSE)
  expect_output(print(result), "reproducr database staleness report")
  expect_output(print(result), "STALE|OK|UNKNOWN")
})

test_that(".assess_staleness() returns 'stale' when current > to_version", {
  expect_equal(.assess_staleness("1.2.0", "1.1.9"), "stale")
  expect_equal(.assess_staleness("4.4.2", "3.6.9"), "stale")
})

test_that(".assess_staleness() returns 'ok' when current <= to_version", {
  expect_equal(.assess_staleness("1.1.0", "1.1.9"), "ok")
  expect_equal(.assess_staleness("3.6.0", "3.6.9"), "ok")
  expect_equal(.assess_staleness("1.1.9", "1.1.9"), "ok")
})

test_that(".assess_staleness() returns 'unknown' for NA current version", {
  expect_equal(.assess_staleness(NA_character_, "1.1.9"), "unknown")
})
