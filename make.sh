#!/bin/bash
set -o errexit -o nounset
cd "$(dirname "$0")"

PREFIX="irl-br-waterway"
TMP="${PREFIX}.$(date -u +%F.%s)"

pyosmium-up-to-date -vv ~/osm-data/britain-and-ireland-latest.osm.pbf || true
osm-lump-ways -i ~/osm-data/britain-and-ireland-latest.osm.pbf -o "${TMP}.geojson" -f waterway=river --min-length-m 100 --timeout-dist-to-longer-s 0 --no-incl-wayids
osm-lump-ways -i ~/osm-data/britain-and-ireland-latest.osm.pbf -o "${TMP}.name.nogroup.geojson" -f waterway -f name --min-length-m 100 --timeout-dist-to-longer-s 0 --no-incl-wayids
osm-lump-ways -i ~/osm-data/britain-and-ireland-latest.osm.pbf -o "${TMP}.name.group-name.geojson" -f waterway -f name -g name --min-length-m 100 --timeout-dist-to-longer-s 0 --no-incl-wayids

tippecanoe -S 10 -y length_m -y root_wayid -l waterway --drop-smallest-as-needed --order-descending-by=length_m -o "${TMP}.pmtiles" "${TMP}.geojson"
tippecanoe -S 10 -y length_m -y root_wayid -l waterway --drop-smallest-as-needed --order-descending-by=length_m -o "${TMP}.name.nogroup.pmtiles" "${TMP}.name.nogroup.geojson"
tippecanoe -S 10 -y length_m -y root_wayid -l waterway --drop-smallest-as-needed --order-descending-by=length_m -o "${TMP}.name.group-name.pmtiles" "${TMP}.name.group-name.geojson"

gzip -9 "${TMP}.geojson"
mv -v "${TMP}.geojson.gz" "./docs/data/${PREFIX}.geojson.gz"
mv -v "${TMP}.pmtiles" "./docs/tiles/${PREFIX}.pmtiles"
