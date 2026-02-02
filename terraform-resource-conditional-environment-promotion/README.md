# Problem: Conditional Resource promotion using count causes resource destroy & recreate

## Problem Statement

When an organization uses single source code for dev, tst and prod and some of the resources are only approved only for dev, most of the time we use `count` to deploy only in dev, By the time we promote the resources to upstream environments (tst/prd), we have to recreate the resources in dev.

## Why this happens

 - Count index resources - resource[0], resource[1], ...
 - Once deployed using count and if you want to remove the `count`,Terraform will remove the indexes from resource[0] --> resource, causing the resource to be destroyed and recreated

## Why this matters

There are cases where resources deployed using `count` may involve storage or ec2 instances - Redeploying may involve losing data

## Observed Constraints (Limited to Org, may vary in other cases)

 - Single source code for all environments
 - Github CICD terraform plan/apply cannot filter resources and apply as it is.

## Desgin Considerations

Avoid using `count` so that Terraform will not index resources.

## Approach (One Possible direction)

Use `for_each` instead of `count`, when deploying resources for a single environment

## Trade-Offs

- `for_each` will identify resources based on key and not based on index positions. No need to recreate resources even if key changes.

- When creating multiple expected resources in dev, tst & prod with same configurations using `count` is preferred as it reduces complexity

