# Markdown table counting the advisories fixed by a bump from $old to $new, per severity.
include "advisories";

fixed($old; $new) as $fixed
| ($fixed | map(.severity) | unique - severities) as $others
| "| Severity | Count |",
  "| --- | ---: |",
  ((severities + $others)[] as $s
   | "| \($s) | \([$fixed[] | select(.severity == $s)] | length) |"),
  "| **Total** | **\($fixed | length)** |"
