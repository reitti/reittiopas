#!/bin/sh

# The osm-extraction JAR is needed to run this script. See https://github.com/reitti/osm-extraction

OSM=$TMPDIR/finland.osm.pbf

function process {
  echo "Processing $2"
  osmosis\
    --read-pbf $OSM\
    --bounding-polygon file=$1\
    --tag-filter accept-ways highway=*\
    --tag-filter reject-ways highway=motorway,motorway_link\
    --tag-filter accept-nodes aeroway=aerodrome amenity=bar,biergarten,cafe,fast_food,food_court,ice_cream,pub,restaurant,college,kindergarten,library,school,university,car_rental,car_sharing,ferry_terminal,fuel,bureau_de_change,baby_hatch,clinic,dentist,doctors,hospital,nursing_home,pharmacy,social_facility,veterinary,arts_centre,cinema,community_centre,fountain,nightclub,social_centre,stripclub,studio,swingerclub,theatre,brothel,courthouse,crematorium,embassy,fire_station,grave_yard,marketplace,place_of_worship,police,post_office,prison,public_building,sauna,townhall historic=monument,memorial leisure=* office=* sport=* tourism=camp_site,caravan_site,chalet,guest_house,hostel,hotel,information,motel,museum,picnic_site,theme_park,zoo railway=station,tram_stop place=locality \
    --tag-filter reject-relations\
    --write-xml -\
   | java -jar ../../osm-extraction/target/osm-extraction-0.1.0-SNAPSHOT-standalone.jar\
   > $2
}

curl http://download.geofabrik.de/openstreetmap/europe/finland.osm.pbf -o $OSM
process polys/helsinki.poly data/helsinki.txt
process polys/espoo.poly data/espoo.txt
process polys/kauniainen.poly data/kauniainen.txt
process polys/kerava.poly data/kerava.txt
process polys/kirkkonummi.poly data/kirkkonummi.txt
process polys/vantaa.poly data/vantaa.txt
rm $OSM



