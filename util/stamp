#!/bin/sh

set -eu

draft=$1
date=$(git log --max-count=1 --format=%ad --date=format:%FT%TZ $1)

sed '/^%%%/,/^%%%/s/\(^date[	 ]*=[	 ]*\).*/\1'$date'/' \
    <$draft >$draft.stamp

if ! diff -u $draft $draft.stamp
then mv $draft.stamp $draft
else rm $draft.stamp
fi
