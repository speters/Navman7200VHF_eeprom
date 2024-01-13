#!/bin/sh
#
# call minipro to read out eeprom, write ihex file, check for changes, list changes in README.md

OUTPREFIX="7200_"
PDEVICE="24c64"

DIR=`pwd`
LAST=$(ls -1  ./*.ihex 2>/dev/null | sed 's/.*_\([0-9]\+\).*/\1/g' | sort -n | tail -1)
if [[ "$LAST" == "" ]] ; then
	LAST=000
fi
NEXT=$(printf "%03d" `expr 1 + $LAST`)
echo $NEXT

minipro -r ${OUTPREFIX}${NEXT}.ihex  -p ${PDEVICE}  -f ihex

diff -q ${OUTPREFIX}${LAST}.ihex ${OUTPREFIX}${NEXT}.ihex >/dev/null
if [ $? -eq 0 ] ; then
  echo "IHEX did not change"
  rm -f ${OUTPREFIX}${NEXT}.ihex

else
  echo -ne "\n## ${OUTPREFIX}${NEXT}\n\n\`\`\`\n" >> README.md
  diff -u0 -uw ${OUTPREFIX}${LAST}.ihex ${OUTPREFIX}${NEXT}.ihex | sed -e 's/\r//g' >> README.md
  echo -ne "\`\`\`\n\n" >> README.md

  git add ${OUTPREFIX}${NEXT}.ihex
fi

