# tests/testthat/test-utils.R

test_that(".parse_renv_lock handles valid JSON lockfile", {
  lock <- tempfile(fileext = ".lock")
  writeLines('{
    "R": {"Version": "4.4.2"},
    "Packages": {
      "dplyr": {"Package": "dplyr", "Version": "1.1.4"},
      "ggplot2": {"Package": "ggplot2", "Version": "3.5.1"}
    }
  }', lock)
  on.exit(unlink(lock))

  result <- reproducr:::.parse_renv_lock(lock)
  expect_type(result, "list")
  expect_true("dplyr" %in% names(result))
  expect_equal(result[["dplyr"]], "1.1.4")
  expect_true("ggplot2" %in% names(result))
})

test_that(".parse_renv_lock returns NULL for missing file", {
  result <- reproducr:::.parse_renv_lock("/nonexistent/path/fake.lock")
  expect_null(result)
})

test_that(".parse_renv_lock returns NULL for invalid JSON", {
  lock <- tempfile(fileext = ".lock")
  writeLines("this is not valid json", lock)
  on.exit(unlink(lock))

  result <- reproducr:::.parse_renv_lock(lock)
  expect_null(result)
})

test_that(".parse_renv_lock returns NULL for empty file", {
  lock <- tempfile(fileext = ".lock")
  file.create(lock)
  on.exit(unlink(lock))

  result <- reproducr:::.parse_renv_lock(lock)
  expect_null(result)
})

test_that(".parse_renv_lock accepts a directory path", {
  tmp <- tempfile()
  dir.create(tmp)
  lock <- file.path(tmp, "renv.lock")
  writeLines('{
    "R": {"Version": "4.4.2"},
    "Packages": {
      "dplyr": {"Package": "dplyr", "Version": "1.1.4"}
    }
  }', lock)
  on.exit(unlink(tmp, recursive = TRUE))

  result <- reproducr:::.parse_renv_lock(tmp)
  expect_type(result, "list")
  expect_equal(result[["dplyr"]], "1.1.4")
})

test_that(".renv_lock_exists returns FALSE when no lockfile present", {
  tmp <- tempfile()
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE))

  result <- reproducr:::.renv_lock_exists(tmp)
  expect_false(result)
})

test_that(".renv_lock_exists returns TRUE when lockfile present", {
  tmp <- tempfile()
  dir.create(tmp)
  lock <- file.path(tmp, "renv.lock")
  writeLines('{"R": {"Version": "4.4.2"}, "Packages": {}}', lock)
  on.exit(unlink(tmp, recursive = TRUE))

  result <- reproducr:::.renv_lock_exists(tmp)
  expect_true(result)
})

test_that(".hash_object returns a non-empty string", {
  result <- reproducr:::.hash_object(list(a = 1, b = "x"))
  expect_type(result, "character")
  expect_true(nchar(result) > 0L)
})

test_that(".hash_object is deterministic", {
  obj <- list(coef = c(1.2, 3.4), n = 100L)
  expect_equal(
    reproducr:::.hash_object(obj),
    reproducr:::.hash_object(obj)
  )
})

test_that(".hash_object differs for different inputs", {
  expect_false(
    reproducr:::.hash_object(list(a = 1)) ==
      reproducr:::.hash_object(list(a = 2))
  )
})

test_that(".get_os returns a non-empty string", {
  result <- reproducr:::.get_os()
  expect_type(result, "character")
  expect_true(nchar(result) > 0L)
})

test_that(".pad pads a string to minimum width", {
  result <- reproducr:::.pad("hi", 10L)
  expect_true(nchar(result) >= 10L)
})

test_that(".pad leaves string unchanged when already wide enough", {
  result <- reproducr:::.pad("hello world", 5L)
  expect_equal(result, "hello world")
})

test_that(".version_in_window returns TRUE for version in window", {
  expect_true(reproducr:::.version_in_window("1.1.0", "1.0.99", "1.2.9"))
})

test_that(".version_in_window returns FALSE for version below window", {
  expect_false(reproducr:::.version_in_window("1.0.0", "1.0.99", "1.2.9"))
})

test_that(".version_in_window returns FALSE for version above window", {
  expect_false(reproducr:::.version_in_window("1.3.0", "1.0.99", "1.2.9"))
})

test_that(".version_in_window returns FALSE for invalid version strings", {
  expect_false(reproducr:::.version_in_window("not-a-version", "1.0.0", "2.0.0"))
})
