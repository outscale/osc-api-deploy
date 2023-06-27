#!/bin/bash
set -e

root=$(cd "$(dirname $0)/" && pwd)
oapi_version=$1

if [ -z "$oapi_version" ]; then
    echo "please set new oapi version as argument. e.g. \"1.27.0\"" 1>&2
    exit 1
fi

oapi_yaml_url="https://raw.githubusercontent.com/outscale/osc-api/${oapi_version}/outscale.yaml"
curl --silent -o "$root/outscale-ori.yaml" "$oapi_yaml_url"

mv "$root/outscale.yaml" "/tmp/outscale.yaml"
$root/hacks/patch.rb "$root/outscale-ori.yaml" "$root/old-outscale.yaml" > "$root/outscale.yaml"
$root/hacks/patch-nooneof.rb "$root/outscale-ori.yaml" > "$root/outscale-java.yaml"
mv "/tmp/outscale.yaml" "$root/old-outscale.yaml"


rm "$root/outscale-ori.yaml"