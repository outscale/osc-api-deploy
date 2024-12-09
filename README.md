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


## FAQ


Q: Why rely on a hack instead of addressing the issue with the SDK generator?

A: There are two problems with upgrading the generator:
- The first issue is that it's not an easy task; it requires porting the patch used by the SDKs and extensive testing to prevent regressions.
- The second problem is that some features, like `oneOf`, would require breaking changes, necessitating a new major version of the SDKs and forcing all clients to upgrade their code.


Q: Then why not just fix the osc-api.yaml file?:

A: Because the API file isn’t technically bugged; it simply uses features that weren’t available when we created the first SDK versions.

Q: Does that mean those strange patches will stay forever?

A: No, at some point, we may upgrade every generator and release new major versions of all relevant SDKs. However, when this happens, we’ll still need to maintain the older SDK versions for a while.

Q: What are recurring bugs that occur during SDK releases?

A: So far, we have encountered two types of bugs that typically break SDK releases
- usage of new features in openapi, that are not supported by generators.
- CI breaks due to an outdated dependency

Q: Why are the hack in ruby ?

A: There is no particular reason. The hacks are very small and could have been written in any language that supports YAML
