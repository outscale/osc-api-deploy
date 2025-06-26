# osc-api-deploy hacks

## Code generator limitations

### oneOf
Some openapi-generator codegens (Rust) don't handle oneOf types with identical types well.
They get confused and the produced code doesn't compile. Typescript codegen 
doesn't support oneOf at all. The only use of oneOf in osc-api is the
following pattern:

```yaml
oneOf:
  - type: string
    format: date
  - type: string
    format: date-string
```
[Rust OneOf](https://github.com/OpenAPITools/openapi-generator/issues/18527)  
[Rust date-time](https://github.com/OpenAPITools/openapi-generator/issues/19319)

### date-time
Some openapi-generator codegens (Go) have erratic implementations of
date-time and date. Go codegen transpiles date-time to time.Time 
(both RFC3339, so that's ok), but doesn't implement date
(which falls back to string). Rust codegen transpiles everything to string.

With current patches, everything is basically passed as string.
It's suboptimal, but it's part of the prototype.

### AWS v4 Signature
Typescript-fetch codegen does not support AWS v4 Signature. PR pending
for typescript-axios.

## Patch
`patch.rb` is a collection of workarounds for code generator limitations.

 - nodatetime: remove date-time format from strings
 - nodate: remove date format from strings
 - nooneof: substitute oneOf for the first type defined
 - noproperties-array: inflate array's items definition
 - patch: apply strategic merge patch in post-process. Should be last resort 
