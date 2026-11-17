# Markdown rows for the published advisories fixed by a bump from $old to $new:
# patched 7.x version newer than $old and not newer than $new. Versions compare
# as number lists, so 7.1.2-9 is older than 7.1.2-31.

def vkey: [scan("\\d+") | tonumber];

def patched:
  .vulnerabilities[]?.patched_versions // empty
  | split(",")[]
  | trim
  | select(startswith("7."));

($old | vkey) as $from
| ($new | vkey) as $to
| [ .[]
    | select(.state == "published" and .withdrawn_at == null)
    | first(patched | select(vkey | . > $from and . <= $to)) as $fixed
    | {key: ($fixed | vkey),
       row: "| [\(.ghsa_id)](\(.html_url)) | \(.cve_id // "-") | \(.severity) | \(.summary | gsub("\\|"; "\\|") | gsub("\\s+"; " ")) | \($fixed) |"} ]
| sort_by(.key)[].row
