AI Validation Summary — Checkpoint 3
Tool Used: Claude (Anthropic)
All six queries were tested by running them directly against bookstore.sqlite using Claude's environment. Each query was verified to return correct results before being finalized.
Issues Found and Fixed

Missing ISBN and genre values — The original ETL script did not include isbn or category in the INSERT INTO BOOK statement, leaving both columns NULL for all books. Claude identified the bug and provided a corrected script.
Empty result for queries (a) and (d) — Filtering on a.last_name LIKE '%Pratchett%' returned no results because the ETL stored the full name "Terry Pratchett" in the first_name column with last_name left blank. The filter was corrected to a.first_name LIKE '%Pratchett%'.