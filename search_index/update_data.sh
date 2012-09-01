#!/bin/sh

OSM=$TMPDIR/finland.osm.pbf

function process {
  osmosis --read-pbf $OSM --bounding-polygon file=$1 --tag-filter accept-ways "highway=*" --tag-filter reject-ways "highway=motorway,motorway_link" --tag-filter reject-relations --tag-filter reject-nodes --write-xml - | grep -E 'k="name"|k="name:fi"' | sed 's|^.*k="name.*v="\(.*\)"/>.*$|\1|p' | sort -u > $2
}

curl http://download.geofabrik.de/osm/europe/finland.osm.pbf -o $OSM
process polys/helsinki.poly data/helsinki.txt
process polys/espoo.poly data/espoo.txt
process polys/kauniainen.poly data/kauniainen.txt
process polys/kerava.poly data/kerava.txt
process polys/kirkkonummi.poly data/kirkkonummi.txt
process polys/vantaa.poly data/vantaa.txt
rm $OSM
