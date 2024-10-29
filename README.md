[![Project Sandbox](https://docs.outscale.com/fr/userguide/_images/Project-Sandbox-yellow.svg)](https://docs.outscale.com/en/userguide/Open-Source-Projects.html)

# Project Goal

This reprository helps deploying [osc-api](https://github.com/outscale/osc-api) yaml for various tooling (SDK, ...)
This may include some yaml hacks to avoid issues with some code generators.
Hack descriptions [here](hacks/README.md)

If you are looking for original Outscale API description in OpenAPI format, please head to [osc-api](https://github.com/outscale/osc-api).

# CI description

## description

[osc-api](https://github.com/outscale/oapi-cli) CI is run when a release happen </br>
It call [release-osc-api](https://github.com/outscale/osc-api/blob/master/.github/workflows/release-osc-api.yml),
which triger [build workflow in osc-api-deploy](https://github.com/outscale/osc-api-deploy/blob/main/.github/workflows/build.yml),
it pass as argument, the current api version.
osc-api-deploy, will rebuild itself calling scrips in [hacks](https://github.com/outscale/osc-api-deploy/tree/main/hacks), and create a new PR for the new release.

Once this PR is merge, osc-api-deploy, will call build.yml for each SDK, thoses SDKs will use either outscale-java.yaml, hacked outscale.yaml(in osc-api-deploy) or original outscale.yaml in osc-api.

Then one PR will be open for each SDKs.

## schema

```
 [osc-api repo]        [osc-api-deploy repo]      [SDKs repos]                   [ oapi-cli ]
       |                        |                      |                              |
   (release)                    |                      |                              |
       V                        |                      |                              |
(release-osc-api.yml)           |                      |                              |
                      \-->(call build.yml)             |                              |
                                V                      |                              |
                       (hack outscale.yaml)            |                              |
                                V                      |                              |
                           (open PR)                   |                              |
                                V                      |                              |
                        (PR manual merge)              V                              |
                                      \---->(start release CI with hacked yaml)       |
                                                       V                              |
                                               (PR for releases)                      |
                                                       V                              |
                                               (PR manual merges)                     |
                                                       \--------------->(osc-sdk-C start oapi-cli CI)
                                                                                      V
                                                                               (PR for release)
                                                                                      V
                                                                               (PR manual merges)
```


