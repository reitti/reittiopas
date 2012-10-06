#!/bin/sh

# The osm-extraction JAR is needed to run this script. See https://github.com/reitti/osm-extraction

OSM=$TMPDIR/finland.osm.pbf

function process {
  echo "Processing $2"
  osmosis\
    --read-pbf $OSM\
    --bounding-polygon file=$1\
    --tag-filter accept-ways \
    --tag-filter accept-nodes \
    --tag-filter reject-relations\
    --write-xml -\
   | java -Xmx1024M -jar ../../osm-extraction/target/osm-extraction-0.1.0-SNAPSHOT-standalone.jar\
   >> $2
}

rm data/helsinki.txt
rm data/espoo.txt
rm data/kauniainen.txt
rm data/kerava.txt
rm data/kirkkonummi.txt
rm data/vantaa.txt

echo "Processing kalkati.net data"
java -Xmx1024M -jar ../../kalkati-extraction/target/kalkati-extraction-0.1.0-SNAPSHOT-standalone.jar\
  Helsinki=data/helsinki.txt\
  Espoo=data/espoo.txt\
  Kauniainen=data/kauniainen.txt\
  Kerava=data/kerava.txt\
  Kirkkonummi=data/kirkkonummi.txt\
  Vantaa=data/vantaa.txt

curl http://download.geofabrik.de/openstreetmap/europe/finland.osm.pbf -o $OSM
process polys/helsinki.poly data/helsinki.txt
process polys/espoo.poly data/espoo.txt
process polys/kauniainen.poly data/kauniainen.txt
process polys/kerava.poly data/kerava.txt
process polys/kirkkonummi.poly data/kirkkonummi.txt
process polys/vantaa.poly data/vantaa.txt
rm $OSM

