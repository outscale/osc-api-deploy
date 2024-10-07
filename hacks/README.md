# osc-api-deploy hacks

3 scripts here, those scripts are use to create outscale-go.yaml, outscale-java.yaml and outscale.yaml

patch-nodatetime.rb take 2 arguments, the API file and the old API file. (so if last api is `1.8`, you need to call `patch-nodatetime.rb osc-api.1.8.json osc-api.1.7.json`) `patch.rb` take the same argument, and `patch-nooneof.rb` only take the API file.

`patch-nooneof.rb` will remove all oneof. `patch.rb` do the same, but also compare the current API to the old one, see if a type change, and if so keep the old one. `patch-nodatetime.rb` do the same as `patch.rb`, but remove all `"format": "date-time"`.

nodatetime was made because go doesn't handle date-time correctly.
