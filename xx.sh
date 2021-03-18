#!/bin/bash
for (( a = 1; a < 10; a++ )); do
echo "this is for $a"
for (( b =1; b < 10; b++ )); do
var1=$[ $a * $b ]
echo "$a x $b = $var1"
done
