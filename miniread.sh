#!/bin/sh
#
#

OUTPREFIX="7200_"

DIR=`pwd`
LAST=$(ls -1  $DIR/*.ihex 2>/dev/null | sed 's/.*_\([0-9]\+\).*/\1/g' | sort -n | tail -1)
if [[ "$LAST" == "" ]] ; then
	LAST=000
fi
NEXT=$(printf "%03d" `expr 1 + $LAST`)
echo $NEXT

minipro -r ${OUTPREFIX}${NEXT}.ihex  -p 24c64  -f ihex

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

