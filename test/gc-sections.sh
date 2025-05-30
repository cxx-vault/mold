#!/bin/bash
. $(dirname $0)/common.inc

cat <<EOF | $CXX -c -o $t/a.o -xc++ - -ffunction-sections -fdata-sections
#include <stdio.h>

int two() { return 2; }

int live_var1 = 1;
int live_var2 = two();
int dead_var1 = 3;
int dead_var2 = 4;

void live_fn1() {}
void live_fn2() { live_fn1(); }
void dead_fn1() {}
void dead_fn2() { dead_fn1(); }

int main() {
  printf("%d %d\n", live_var1, live_var2);
  live_fn2();
}
EOF

$CXX -B. -o $t/exe1 $t/a.o
readelf --symbols $t/exe1 > $t/log1
$QEMU $t/exe1 | grep '1 2'

grep live_fn1 $t/log1
grep live_fn2 $t/log1
grep dead_fn1 $t/log1
grep dead_fn2 $t/log1
grep live_var1 $t/log1
grep live_var2 $t/log1
grep dead_var1 $t/log1
grep dead_var2 $t/log1

$CXX -B. -o $t/exe2 $t/a.o -Wl,-gc-sections
readelf --symbols $t/exe2 > $t/log2
$QEMU $t/exe2 | grep '1 2'

grep live_fn1 $t/log2
grep live_fn2 $t/log2
not grep dead_fn1 $t/log2
not grep dead_fn2 $t/log2
grep live_var1 $t/log2
grep live_var2 $t/log2
not grep dead_var1 $t/log2
not grep dead_var2 $t/log2
