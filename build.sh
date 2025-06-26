#!/bin/env bash

set -euo pipefail

if [ ! -v "1" ]; then
    echo "please set new oapi version as argument. e.g. \"1.35.3\"" 1>&2
    exit 1
fi

root=$(cd "$(dirname $0)/" && pwd)
oapi_version=$1

oapi_yaml_url="https://raw.githubusercontent.com/outscale/osc-api/${oapi_version}/outscale.yaml"
oapi_yaml="$(mktemp outscale.XXXXXX.yaml)"
curl --silent --retry 5 -o "${oapi_yaml}" "${oapi_yaml_url}"

cleanup() {
	rm "${oapi_yaml}" || true
}
trap cleanup EXIT

$root/hacks/patch.rb --nooneof --patch "${root}/hacks/outscale.patch.yaml" --input "${oapi_yaml}" > "$root/outscale.yaml"
$root/hacks/patch.rb --nooneof --nodatetime --patch "${root}/hacks/outscale-go.patch.yaml" --input "${oapi_yaml}" > "$root/outscale-go.yaml"
$root/hacks/patch.rb --noproperties-array --input "${oapi_yaml}" > "$root/outscale-c.yaml"
