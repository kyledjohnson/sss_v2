#!/bin/sh

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

SEVENTEENSEVENTYSIXD=${SEVENTEENSEVENTYSIXD:-$SRCDIR/seventeenseventysixd}
SEVENTEENSEVENTYSIXCLI=${SEVENTEENSEVENTYSIXCLI:-$SRCDIR/seventeenseventysix-cli}
SEVENTEENSEVENTYSIXTX=${SEVENTEENSEVENTYSIXTX:-$SRCDIR/seventeenseventysix-tx}

[ ! -x $SEVENTEENSEVENTYSIXD ] && echo "$SEVENTEENSEVENTYSIXD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
SSSVERSTR=$($SEVENTEENSEVENTYSIXCLI --version | head -n1 | awk '{ print $NF }')
SSSVER=$(echo $SSSVERSTR | awk -F- '{ OFS="-"; NF--; print $0; }')
SSSCOMMIT=$(echo $SSSVERSTR | awk -F- '{ print $NF }')

# Create a footer file with copyright content.
# This gets autodetected fine for seventeenseventysixd if --version-string is not set,
# but has different outcomes for seventeenseventysix-cli.
echo "[COPYRIGHT]" > footer.h2m
$SEVENTEENSEVENTYSIXD --version | sed -n '1!p' >> footer.h2m

for cmd in $SEVENTEENSEVENTYSIXD $SEVENTEENSEVENTYSIXCLI $SEVENTEENSEVENTYSIXTX; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=$SSSVER --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-$SSSCOMMIT//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
