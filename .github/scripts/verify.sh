#!/usr/bin/env bash
# Post-apply verification: the ALB has enough healthy targets, and the page it
# serves was rendered with data from the database (web -> DB works end to end).
set -euo pipefail

TIMEOUT_SECONDS=900   # fresh environments need time: instances boot, MySQL installs
POLL_SECONDS=20

cd terraform
ALB_DNS=$(terraform output -raw alb_dns_name)
TG_ARN=$(terraform output -raw target_group_arn)
MIN_HEALTHY=$(terraform output -raw asg_min_size)

summary() { echo "$1" >> "$GITHUB_STEP_SUMMARY"; }
summary "## Post-apply verification"

# --- Check 1: target group health (proves instances booted and the Lambda registered them)
echo "Waiting for at least $MIN_HEALTHY healthy targets..."
deadline=$((SECONDS + TIMEOUT_SECONDS))
while true; do
  healthy=$(aws elbv2 describe-target-health --target-group-arn "$TG_ARN" \
    --query "length(TargetHealthDescriptions[?TargetHealth.State=='healthy'])" --output text)
  echo "  healthy targets: $healthy"
  if [ "$healthy" -ge "$MIN_HEALTHY" ]; then break; fi
  if [ "$SECONDS" -ge "$deadline" ]; then
    summary "- ❌ Only $healthy/$MIN_HEALTHY healthy targets after $((TIMEOUT_SECONDS / 60)) minutes"
    echo "::error::Only $healthy/$MIN_HEALTHY healthy targets"
    exit 1
  fi
  sleep "$POLL_SECONDS"
done
summary "- ✅ $healthy healthy targets in the target group"

# --- Check 2: the page through the ALB shows data from the database.
# nginx answers 200 even when PHP can't reach MySQL, so check the content, not the status.
echo "Checking http://$ALB_DNS/ ..."
deadline=$((SECONDS + TIMEOUT_SECONDS))
while true; do
  body=$(curl -s --max-time 10 "http://$ALB_DNS/" || true)
  if echo "$body" | grep -q "Total visits recorded"; then break; fi
  echo "  not ready yet: $(echo "$body" | head -c 120)"
  if [ "$SECONDS" -ge "$deadline" ]; then
    summary "- ❌ Site did not serve database-backed content. Last response: \`$(echo "$body" | head -c 200)\`"
    echo "::error::Site did not serve database-backed content"
    exit 1
  fi
  sleep "$POLL_SECONDS"
done
summary "- ✅ http://$ALB_DNS/ serves pages with data from the database"
echo "All checks passed."
