# Problem: Orphaned resources causes Application Outage / consume resources


## Problem Statement

In AWS EKS Environments, for posit workbench applications (pod/user- session), once user session is completed, the relevant resources(Pod, Service, Jobs, Replicaset) must be removed but these resources exist for some time causing issues like resource consumption to application outage

## Why this happens

 - User creates session,Backend (k8s)- Creates job, pod, svc
 - User completes the session - resources should be removed
 - But pod exists - resources consumption,svc exist -causing HTTP 502 error

## Why this matters

 - Let's assume user starts a new session in posit workbench, and quits the session, upon quit the pod status should be `Completed` and if these pods are not removed,it will still consume IP address, CPU/Memory

  `Solution`: Set TTL in helm chart E.g.  job.ttlSecondsAfterFinished: 300 (After 5 minutes)

- Another test case is if user session pod is not in running state - Pending, Error, Terminated, Completed - still it needs to be monitored and removed if not needed.

- Another test case - if a user clicks on new session in posit workbench - as described above, a new pod, job, svc is created , upon session completion, if svc is not removed and later a new session with same name is created then it leads to HTTP 502 Error

## Observed Constraints

 - Multiple User Sessions
 - Sometimes Orphaned services get removed upon 24Hrs
 - Upon setting TTL, completed pods get removed but still pending/crashloopbackoff pods exists

## Desgin Considerations

 - Detect Orphaned pods & services and remove these by human intervension to cleanup resources using bash script

## Approach (One Possible direction)

### For Orphaned pods

- Any session scoped Pods that is not running will be captured


### For Orphaned Services - Upon comparing - label - job-name matches in pods, services, jobs

- Any session scoped services whose job-name label matches with pod job-name label, its considered as active service in use
- If the job-name label of service didn't match with pod we mark them as orphaed service

## Trade-Offs

- This script only detects the orphaned pods,services. no cleanup, manual intervention is required.
- This script works for only kubernetes backed posit workbench user sessions.
- Even configuring it as cronjob, Engineers still need to monitor this script and cleanup resources