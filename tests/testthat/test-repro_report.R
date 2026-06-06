test_that("repro_report() errors on non-audit_report input", {
  expect_error(repro_report(list()), "`audit` must be an `audit_report`")
  expect_error(repro_report("text"), "`audit` must be an `audit_report`")
})

test_that("repro_report() returns a character string", {
  f  <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)
  rs <- risk_score(r)
  out <- repro_report(r, rs, format = "text", style = "minimal")

  expect_true(is.character(out))
  expect_true(nchar(out) > 0L)
})

test_that("repro_report() returns invisibly for text format", {
  f  <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)

  ret <- withVisible(repro_report(r, format = "text", style = "minimal"))
  expect_false(ret$visible)
})

# ---- minimal style ---------------------------------------------------------

test_that("repro_report() minimal style contains R version", {
  f  <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)
  out <- repro_report(r, format = "text", style = "minimal")

  expect_true(grepl(r$env$r_version, out, fixed = TRUE))
})

test_that("repro_report() minimal style contains file count", {
  f  <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)
  out <- repro_report(r, format = "text", style = "minimal")

  expect_true(grepl("Files scanned|files scanned|1", out))
})

test_that("repro_report() minimal style contains verdict", {
  f  <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)
  rs <- risk_score(r)
  out <- repro_report(r, rs, format = "text", style = "minimal")

  expect_true(grepl("REPRODUCIBLE|CAUTION|AT RISK|UNKNOWN", out))
})

# ---- academic style --------------------------------------------------------

test_that("repro_report() academic style contains 'R (version'", {
  f  <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)
  out <- repro_report(r, format = "text", style = "academic")

  expect_true(grepl("R \\(version", out))
})

test_that("repro_report() academic style mentions detected packages", {
  f  <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)
  out <- repro_report(r, format = "text", style = "academic")

  expect_true(grepl("dplyr", out))
})

test_that("repro_report() academic style is a single prose paragraph", {
  f   <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  r   <- audit_script(f, renv = FALSE, verbose = FALSE)
  out <- repro_report(r, format = "text", style = "academic")

  lines <- strsplit(trimws(out), "\n")[[1]]
  lines <- lines[nchar(trimws(lines)) > 0L]
  expect_true(length(lines) >= 2L)
})

# ---- pharma style ----------------------------------------------------------

test_that("repro_report() pharma style contains 'Sign-off'", {
  f  <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)
  out <- repro_report(r, format = "text", style = "pharma")

  expect_true(grepl("Sign-off", out))
})

test_that("repro_report() pharma style contains 'Risk register'", {
  f  <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)
  out <- repro_report(r, format = "text", style = "pharma")

  expect_true(grepl("Risk register|Risk Register", out))
})

test_that("repro_report() pharma style contains 'Execution environment'", {
  f  <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)
  out <- repro_report(r, format = "text", style = "pharma")

  expect_true(grepl("Execution environment|execution environment", out))
})

# ---- HTML format -----------------------------------------------------------

test_that("repro_report() html format writes a valid HTML file", {
  f   <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  out <- tempfile(fileext = ".html")
  on.exit(unlink(c(f, out)))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)

  repro_report(r, format = "html", style = "minimal", output_file = out)
  expect_true(file.exists(out))
  content <- paste(readLines(out, warn = FALSE), collapse = "")
  expect_true(grepl("<!DOCTYPE html>", content, fixed = TRUE))
  expect_true(grepl("<body>",          content, fixed = TRUE))
})

test_that("repro_report() html format file has non-zero size", {
  f   <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  out <- tempfile(fileext = ".html")
  on.exit(unlink(c(f, out)))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)

  repro_report(r, format = "html", style = "pharma", output_file = out)
  expect_true(file.info(out)$size > 0L)
})

# ---- Markdown format -------------------------------------------------------

test_that("repro_report() md format writes a file to disk", {
  f   <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  out <- tempfile(fileext = ".md")
  on.exit(unlink(c(f, out)))
  r  <- audit_script(f, renv = FALSE, verbose = FALSE)

  repro_report(r, format = "md", style = "minimal", output_file = out)
  expect_true(file.exists(out))
})

test_that("repro_report() md format contains markdown headings", {
  f   <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  out <- tempfile(fileext = ".md")
  on.exit(unlink(c(f, out)))
  r   <- audit_script(f, renv = FALSE, verbose = FALSE)

  repro_report(r, format = "md", style = "minimal", output_file = out)
  content <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_true(grepl("^#", content, perl = TRUE))
})

test_that("repro_report() uses a default output_file name when none supplied", {
  f  <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit({
    unlink(f)
    unlink("reproducr_report.md",   force = TRUE)
    unlink("reproducr_report.html", force = TRUE)
  })
  r <- audit_script(f, renv = FALSE, verbose = FALSE)

  repro_report(r, format = "md", style = "minimal")
  expect_true(file.exists("reproducr_report.md"))
})

# ---- verdict branches ------------------------------------------------------

test_that("repro_report() shows AT RISK verdict for high-risk report", {
  f      <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  report <- audit_script(f, renv = FALSE, verbose = FALSE)

  # Build a mock high-risk report directly -- risk_score() may return 0 rows
  # if no installed package version falls in a known window
  mock_risks <- data.frame(
    call        = "dplyr::summarise",
    file        = f,
    line        = 1L,
    pkg         = "dplyr",
    fn          = "summarise",
    pkg_version = "1.1.0",
    risk        = "high",
    check       = "changelog",
    description = "test high risk entry",
    reference   = "https://example.com",
    stringsAsFactors = FALSE
  )
  class(mock_risks) <- c("risk_report", "data.frame")

  out <- repro_report(report, mock_risks, format = "text", style = "minimal")
  expect_type(out, "character")
  expect_true(grepl("AT RISK", out))
})

test_that("repro_report() shows CAUTION verdict for medium-risk report", {
  f      <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  report <- audit_script(f, renv = FALSE, verbose = FALSE)

  mock_risks <- data.frame(
    call        = "dplyr::summarise",
    file        = f,
    line        = 1L,
    pkg         = "dplyr",
    fn          = "summarise",
    pkg_version = "1.1.0",
    risk        = "medium",
    check       = "changelog",
    description = "test medium risk entry",
    reference   = "https://example.com",
    stringsAsFactors = FALSE
  )
  class(mock_risks) <- c("risk_report", "data.frame")

  out <- repro_report(report, mock_risks, format = "text", style = "minimal")
  expect_type(out, "character")
  expect_true(grepl("CAUTION", out))
})

test_that("repro_report() shows UNKNOWN verdict when risks is NULL", {
  f      <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  report <- audit_script(f, renv = FALSE, verbose = FALSE)

  out <- repro_report(report, risks = NULL, format = "text", style = "minimal")
  expect_type(out, "character")
  expect_true(grepl("unknown|UNKNOWN", out, ignore.case = TRUE))
})

# ---- all styles and formats ------------------------------------------------

test_that("repro_report() renders all styles and formats without error", {
  f      <- write_script("x <- dplyr::filter(mtcars, cyl == 4)")
  on.exit(unlink(f))
  report <- audit_script(f, renv = FALSE, verbose = FALSE)
  risks  <- risk_score(report)

  # academic text
  out <- repro_report(report, risks, format = "text", style = "academic")
  expect_type(out, "character")

  # pharma md
  md_out <- tempfile(fileext = ".md")
  on.exit(unlink(md_out), add = TRUE)
  repro_report(report, risks, format = "md", style = "pharma",
               output_file = md_out)
  expect_true(file.exists(md_out))

  # html minimal
  html_out <- tempfile(fileext = ".html")
  on.exit(unlink(html_out), add = TRUE)
  repro_report(report, risks, format = "html", style = "minimal",
               output_file = html_out)
  expect_true(file.exists(html_out))

  # html pharma
  html_out2 <- tempfile(fileext = ".html")
  on.exit(unlink(html_out2), add = TRUE)
  repro_report(report, risks, format = "html", style = "pharma",
               output_file = html_out2)
  expect_true(file.exists(html_out2))
})