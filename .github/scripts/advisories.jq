# Published advisories fixed by a bump from $old to $new: patched 7.x version
# newer than $old and not newer than $new. Versions compare as number lists, so
# 7.1.2-9 is older than 7.1.2-31.

def vkey: [scan("\\d+") | tonumber];

def severities: ["critical", "high", "medium", "low"];

def severity_rank: . as $s | severities | index($s) // length;

def patched:
  .vulnerabilities[]?.patched_versions // empty
  | split(",")[]
  | trim
  | select(startswith("7."));

# Most severe first, then by fixed version.
def fixed($old; $new):
  ($old | vkey) as $from
  | ($new | vkey) as $to
  | [ .[]
      | select(.state == "published" and .withdrawn_at == null)
      | first(patched | select(vkey | . > $from and . <= $to)) as $fixed
      | {ghsa_id, html_url, cve_id, severity: (.severity // "unknown"), summary, fixed: $fixed} ]
  | sort_by((.severity | severity_rank), (.fixed | vkey));
