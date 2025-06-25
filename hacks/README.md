# osc-api-deploy hacks

## Code generator limitations

### oneOf
Some openapi-generator's codegen (Rust) don't like oneOf types with identical type.
It get confused and the produced code don't compile. Typescript Codegen 
don't support OneOf at all. the only use of oneOf in osc-api is the
following pattern

```yaml
oneOf:
  - type: string
    format: date
  - type: string
    fromat: date-string
```
[Rust OneOf](https://github.com/OpenAPITools/openapi-generator/issues/18527)
[Rust date-time](https://github.com/OpenAPITools/openapi-generator/issues/19319)

### date-time
Some openapi-generator's codegen (Go) have herattic implementation of
date-time and date. Go Codegen transpile date-time to time.Time 
(both RFC3339, so it's ok), but don't implemente date
(which fallback into string). Rust Codegen transpile everything to string

With actual patches, everything is baslicly passed at string.
suboptimal but it's part of the prototype

### AWS v4 Siguature
Typescript-fetch codegen does not support AWS v4 Siguature. PR prending
for typescript-axios.

## Patch
`patch.rb` is a collections of workarounds for code generators limitations.

 - nodatetime: remove date-time format from strings
 - nodate: remove date format from strings
 - nooneof: substitube oneOf for the first type defined
 - noproperties-array: inflate array's items definition
 - patch: apply strategic merge patch in post-process. Should be last resort 
