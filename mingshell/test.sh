#!/bin/bash


num=$(sed -n 1p ming)
t=$(date)
echo $t
echo $num

if [ "$num" == "" ]
then 
  echo "none"
else
  echo $(($num + 10 ))
fi

