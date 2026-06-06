## R CMD check results
0 errors | 0 warnings | 1 note

* checking for future file timestamps: unable to verify current time
  Known infrastructure issue, unrelated to the package.

## Test environments
* macOS 26.5, R 4.4.2 (local)
* Windows (R-devel, win-builder): 0 errors, 0 warnings, 2 notes

## Downstream dependencies
None.

## Resubmission notes
This is a resubmission of v0.1.2 (previously submitted 2026-06-06).
Changes since v0.1.2:

* Fixed bug in `.resolve_current_versions()` where packages appearing in
  multiple library paths caused a "more elements supplied than there are
  to replace" error. Now takes only the first match.

* Added MIT LICENSE file and LICENSE.md (previously missing).
