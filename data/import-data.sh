#!/bin/bash
# 
#  curl commands to reload the data from the previous tutorial
#
#

set -e

printf "Loading Campus context data "

#
# Create Campus Entities
#
curl -s -o /dev/null -X POST \
  'http://orion:1026/v2/op/update' \
  -H 'Content-Type: application/json' \
  -g -d '{
  "actionType": "append",
  "entities": [
      {
        "id":"urn:ngsi-ld:Campus:001",
        "type":"Campus",
        "name":{"type":"Text","value":"UFC - Campus do Pici"},
        "description":{"type":"Text","value":"Universidade Federal do Ceara - Campus do Pici"},
        "address":{"type":"PostalAddress","value":{"streetAddress":"Av. Mister Hull, s/n","addressRegion":"Fortaleza","addressLocality":"Pici","postalCode":"60455-76"}},
        "location":{"type":"geo:json","value":{"type":"Point","coordinates":[-3.74574,-38.57404]}},              
        "brokerAddress":{"type":"Text","value":"10.0.10.68"}
      }
   ]
}'

curl -s -o /dev/null -X POST \
  'http://orion:1026/v2/op/update' \
  -H 'Content-Type: application/json' \
  -g -d '{
  "actionType": "append",
  "entities": [
      {
        "id":"urn:ngsi-ld:Campus:002",
        "type":"Campus",
        "name":{"type":"Text","value":"UFC - Campus Quixada"},
        "description":{"type":"Text","value":"Universidade Federal do Ceara - Campus de Quixada"},
        "address":{"type":"PostalAddress","value":{"streetAddress":"Av. Jose de Freitas Queiroz, 5003","addressRegion":"Quixada","addressLocality":"Cedro","postalCode":"63902-580"}},
        "location":{"type":"geo:json","value":{"type":"Point","coordinates":[-4.97847,-39.05645]}},
        "brokerAddress":{"type":"Text","value":"10.0.200.2"}
      }
   ]
}'

