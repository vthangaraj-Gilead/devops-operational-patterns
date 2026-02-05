#!/bin/bash

#set -x

## Set Namespace
NAMESPACE="rstudioworkbench"

### Enable logging
LOG_FILE="/var/log/orphaned_script_logger.log"

# A function to log messages with a timestamp
log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

## Identify Orphaned / Unused Pods

orphaned_pods=$(kubectl get pods -l job-name -n "$NAMESPACE" --field-selector status.phase!=Running -o jsonpath='{.items[*].metadata.name}{"\n"}')

log_message "********* START *********"

log_message "********* Orphaned POD Resources *********"

if [[ -n "$orphaned_pods" ]]; then
  log_message "Orphaned pods detected:"
  while read -r pod; do
    [[ -z "$pod" ]] && continue
    log_message " - $pod"
  done <<< "$orphaned_pods"
else
  log_message "No orphaned pods found"
fi
log_message "********* Orphaned Service Resources *********"

## Identify Orphaned Services

orphan_found=false

ACTIVE_JOBS=$(kubectl get pods -n "$NAMESPACE" \
  --field-selector=status.phase=Running \
  -o jsonpath='{range .items[*]}{.metadata.labels.job-name}{"\n"}{end}')

while IFS="|" read -r service_name selector_job; do
  [[ -z "$selector_job" ]] && continue

  if ! echo "$ACTIVE_JOBS" | grep -Fxq "$selector_job"; then
    log_message "ORPHAN SERVICE: $service_name"
    orphan_found=true
  fi

done < <(
  kubectl get svc -n "$NAMESPACE" \
    -o jsonpath='{range .items[*]}{.metadata.name}{"|"}{.spec.selector.job-name}{"\n"}{end}'
)

if [[ "$orphan_found" == false ]]; then
  log_message "No orphaned services found"
fi

log_message "********* END *********"