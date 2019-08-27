#!/usr/bin/env bash

workdir="$1"
libdir="$workdir"/lib
srcdir="$workdir"/scripts

shift 1

classpath="$srcdir"
for jar in "$libdir"/*.jar; do
  classpath=$classpath:$jar
done

groovy -cp "$classpath" "$srcdir"/DBSetup.groovy $*
exit $?
