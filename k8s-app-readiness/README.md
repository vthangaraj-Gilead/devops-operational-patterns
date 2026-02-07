# Problem: User not able to access applications after upgrade / maintainence

## Problem Statement

DevOps Team updates application on maintainenece period - App Version / Helm Chart Version / Resolve Bugs / New features - after upgrade, even though pod is running application is not accessible

## Why this happens

Application services may fail internally due to many reasons.

 - Not able to connect to Database.
 - Upgrade may have silent breaking changes - pod may run but app not accessible.
 - Updating incorrect licences.

## Why this matters

When pods are running, assumption is everything looks fine. but application fails silently affecting users resulting in outages.

## Observed Constraints

- App Helm chart deployed via TF(helm_release) in Github Actions. So CICD will be success if pod is in running state cannot confirm application is accessible.

- Traffic is routed to irrespective of application is accessible or non-accessible.

## Desgin Considerations

- Route traffic to applications only app says its okay to accept traffic

## Approach (One Possible direction)

- Enable Readiness Probe in Helm Charts for applications and configure /health-checks of App in readiness probe so that app sends HTTP 200 request if its healthy.

## Trade-Offs

- With readiness probe enabled, apps will not receive in that pod, if the app crashes internally, still need to troubleshoot to resolve the issue