#!/bin/sh

curl http://download.geofabrik.de/osm/europe/finland.osm.bz2 | bunzip2 | osmosis --read-xml - --bounding-polygon file=area.poly --tag-filter accept-ways "highway=*" --tag-filter reject-relations --tag-filter reject-nodes --write-xml - | grep 'k="name' | sed 's|^.*k="name.*v="\(.*\)"/>.*$|\1|p' | sort -u > streets.txt
