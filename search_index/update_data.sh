#!/bin/sh

OSM=$TMPDIR/finland.osm.bz2

curl http://download.geofabrik.de/osm/europe/finland.osm.bz2 -o $OSM
bzcat $OSM | osmosis --read-xml - --bounding-polygon file=polys/espoo.poly --tag-filter accept-ways "highway=*" --tag-filter reject-relations --tag-filter reject-nodes --write-xml - | grep -E 'k="name"|k="name:fi"' | sed 's|^.*k="name.*v="\(.*\)"/>.*$|\1|p' | sort -u > data/espoo.txt
bzcat $OSM | osmosis --read-xml - --bounding-polygon file=polys/helsinki.poly --tag-filter accept-ways "highway=*" --tag-filter reject-relations --tag-filter reject-nodes --write-xml - | grep -E 'k="name"|k="name:fi"' | sed 's|^.*k="name.*v="\(.*\)"/>.*$|\1|p' | sort -u > data/helsinki.txt
bzcat $OSM | osmosis --read-xml - --bounding-polygon file=polys/kauniainen.poly --tag-filter accept-ways "highway=*" --tag-filter reject-relations --tag-filter reject-nodes --write-xml - | grep -E 'k="name"|k="name:fi"' | sed 's|^.*k="name.*v="\(.*\)"/>.*$|\1|p' | sort -u > data/kauniainen.txt
bzcat $OSM | osmosis --read-xml - --bounding-polygon file=polys/kerava.poly --tag-filter accept-ways "highway=*" --tag-filter reject-relations --tag-filter reject-nodes --write-xml - | grep -E 'k="name"|k="name:fi"' | sed 's|^.*k="name.*v="\(.*\)"/>.*$|\1|p' | sort -u > data/kerava.txt
bzcat $OSM | osmosis --read-xml - --bounding-polygon file=polys/kirkkonummi.poly --tag-filter accept-ways "highway=*" --tag-filter reject-relations --tag-filter reject-nodes --write-xml - | grep -E 'k="name' | sed 's|^.*k="name.*v="\(.*\)"/>.*$|\1|p' | sort -u > data/kirkkonummi.txt
bzcat $OSM | osmosis --read-xml - --bounding-polygon file=polys/vantaa.poly --tag-filter accept-ways "highway=*" --tag-filter reject-relations --tag-filter reject-nodes --write-xml - | grep -E 'k="name"|k="name:fi"' | sed 's|^.*k="name.*v="\(.*\)"/>.*$|\1|p' | sort -u > data/vantaa.txt
#rm $TMPDIR/finland.osm.bz2
