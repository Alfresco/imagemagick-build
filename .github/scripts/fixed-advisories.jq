# Markdown rows for the published advisories fixed by a bump from $old to $new:
# patched 7.x version newer than $old and not newer than $new. Versions compare
# as number lists, so 7.1.2-9 is older than 7.1.2-31.

def vkey: [scan("\\d+") | tonumber];

def patched:
  [ .vulnerabilities[]?.patched_versions // empty
    | split(",")[]
    | gsub("^\\s+|\\s+$"; "")
    | select(startswith("7.")) ];

($old | vkey) as $from
| ($new | vkey) as $to
| [ .[]
    | select(.state == "published" and .withdrawn_at == null)
    | ([patched[] | select((vkey) > $from and (vkey) <= $to)] | first) as $fixed
    | select($fixed != null)
    | {ghsa: .ghsa_id, url: .html_url, cve: (.cve_id // "-"), sev: .severity,
       summary: (.summary | gsub("\\|"; "\\|") | gsub("\\s+"; " ")), fixed: $fixed} ]
| sort_by(.fixed | vkey)
| .[]
| "| [\(.ghsa)](\(.url)) | \(.cve) | \(.sev) | \(.summary) | \(.fixed) |"
