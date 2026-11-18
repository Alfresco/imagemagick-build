# Markdown table rows for the advisories fixed by a bump from $old to $new.
include "advisories";

fixed($old; $new)[]
| "| [\(.ghsa_id)](\(.html_url)) | \(.cve_id // "-") | \(.severity) | \(.summary | gsub("\\|"; "\\|") | gsub("\\s+"; " ")) | \(.fixed) |"
