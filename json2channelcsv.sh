#!/bin/sh
#

JSONFILE="7200_eeprom_decode.json"
CSVFILE="7200_channels.csv"
echo "type,id,name,bf1,bf2,bf3,bf" > ${CSVFILE}
jq -r '.channels_dsc[] | [.type, .id, .name, .bf1, .bf2, .bf3, .bf] | @csv' ${JSONFILE} >> ${CSVFILE}
jq -r '.channels_atis[] | [.type, .id, .name, .bf1, .bf2, .bf3, .bf] | @csv' ${JSONFILE} >> ${CSVFILE}
