# Problem: Not able to pin stable imageswhen using mutable tags

## Problem Statement

When using a reusable docker CICD Pipeline workfow with mutable tags, incase of application breaks with the current docker configuration, there is no rollback available, so until app developer identifies fix and rerun the CICD container, the app stays broken.

## Why this happens

There is no way to pin stable version images when using mutable tags, if we are using immutable tags, app team will have dependency with devops team to update the image tag everytime they run cicd pipeline

## Why this matters

 - No Rollback available
 - No stable version
 - Prod Env breaks easily

## Observed Constraints

 - Reusable docker CICD Workflow for docker build [no control of the config when used in caller repository]
 - Mutable ECR Image Tags to reduce dependency

## Desgin Considerations

 - Make rollback available to last stable version

## Approach (One Possible direction)

Upon Successful docker build, introduce 2 new jobs - Approval & Tag `Prod-Stable`

Flow: User runs workflow --> Docker build success --> User validates application -->In github after docker build goes to Approval (Job2) --> Approve if User finds the current docker build stable --> Goes to Tag `Prod-Stable`, tags cuurent commit as `Prod-Stable`.

When application breaks, user can rerun the docker workflow with Tag `Prod-Stable` to rollback to last stable version

## Trade-Offs

 - `Prod-Stable` is only used to rollback to last stable version incase of app breaks and developers doesn't have immediate fix.
 - Not providing approval will result in new stable changes are not reflected in`Prod-Stable`
 - If docker build is successful but app breaks, Rejecting approval doesnt mean the current image tag will fix automatically, developers will still have to fix the code and rerun the pipeline
 - `Prod-Stable` will contain the last stable commit, if any changes are introduced, say workflow file(.github/workflow.yaml) is updated in the current main/master unless the pipeline is run against this main/master and provide approval to make sure the `Prod-Stable` contains the latest stable changes.
 - Not parallel run is expected, if so the latest run approval wins i.e. the latest run changes will point to `Prod-Stable`