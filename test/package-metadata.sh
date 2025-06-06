#!/bin/bash
. $(dirname $0)/common.inc

cat <<EOF | $CC -o $t/a.o -c -xc -
#include <stdio.h>
int main() {
  printf("Hello world\n");
}
EOF

$CC -B. -o $t/exe1 $t/a.o -Wl,-package-metadata='{"foo":"bar"}'
readelf -x .note.package $t/exe1 | grep -F '{"foo":"bar"}'

$CC -B. -o $t/exe2 $t/a.o -Wl,--package-metadata='%7B%22foo%22%3A%22bar%22%7D'
readelf -x .note.package $t/exe2 | grep -F '{"foo":"bar"}'

not $CC -B. -o $t/exe3 $t/a.o -Wl,--package-metadata='foo%x' |&
  grep 'invalid string: foo%x'
