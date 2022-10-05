# Red Hat Chaos Engineering GitHub Actions

This repository contains [composite actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) and [reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows#creating-a-reusable-workflow) used in Red Hat Chaos Engineering organization

## Composite actions

All code examples need to be adapted to your existing or new workflow file in your `.github/workflows` folder inside the repository where you want the workflow to run.

### KinD

```
⁞

jobs:
  ⁞
    ⁞
    steps:
      - name: Check out code
        uses: actions/checkout@v3
      - name: Create multi-node KinD cluster
        uses: arcalot/actions/kind@main
      ⁞
```


#### '.kind-config.yml' File Usage

It is a template that can be copied over to the root of the repository where the composite action is used and multi-node KinD cluster is needed.
