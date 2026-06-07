---
name: Suggest a database entry
about: Suggest a new breaking-change entry for risk_score()
title: '[DB] pkg::fn -- brief description'
labels: database
assignees: ''
---

## Function
`pkg::fn` (e.g. `dplyr::summarise`)

## What changed
Brief description of the silent breaking change and how it affects results.

## Version window
- Last safe version (`from_version`):
- First risky version (`to_version`):

## Risk level
- [ ] high -- output values change silently
- [ ] medium -- argument renamed/deprecated
- [ ] low -- minor behavioural note

## Evidence
Link to the changelog, CRAN NEWS, or GitHub release:

## Note
To submit the actual JSON entry, open a PR on
[repro-stats/reproducr-db](https://github.com/repro-stats/reproducr-db)
following the [contributing guide](https://github.com/repro-stats/reproducr-db/blob/main/CONTRIBUTING.md).
