#!/bin/bash

rule_file=/root/squid/rules.conf
ip_file=/root/squid/destination_ip.conf
domain_file=/root/squid/destination_domain.conf
port_file=/root/squid/port.conf
temp_file=$(mktemp /tmp/rule_num.XXX)
cat $rule_file |grep -v -E '^$|^#'|awk '{print $4,$5}'|uniq -c >> $temp_file

IFS.OLD=$IFS
IFS=$'\n'
echo

echo "---chech if each port rules are 4 lines---"
sleep 2
echo
echo
for i in $(cat $temp_file);do
  if [[ $(echo $i|awk '{print $1}') -ne 4 ]];then
    echo "format error please check $i"
  fi
done

echo

echo "---check if dst_ip or dst_domain are in destination_domain---"
sleep 2
echo 
echo
for b in $(cat $rule_file |grep -v -E '^$|^#'|awk '{print $4}'|grep 'dst_domain');do 
  grep  $b $domain_file &>/dev/null
  if [[ $(echo $?) -ne 0 ]];then
    echo "$b could not found in $domain_file"
  fi
done

for c in $(cat $rule_file |grep -v -E '^$|^#'|awk '{print $4}'|grep 'dst_ip');do 
  grep  $c $ip_file &>/dev/null
  if [[ $(echo $?) -ne 0 ]];then
    echo "$c could not found in $ip_file"
  fi
done
echo
echo
echo " ---check if port_xxxx in port.conf---"

for d in $(cat $rule_file |grep -v -E '^$|^#'|awk '{print $5}'|grep 'port');do 
  grep  $d $port_file &>/dev/null
  if [[ $(echo $?) -ne 0 ]];then
    echo "port $d could not found in $port_file"
  fi
done


echo "--- start to check writing norms for each file---"
echo
echo

echo "start to check $domain_file"
egrep -v 'acl' $domain_file
if [[ $(echo $?) -ne 1 ]];then
 echo "please add acl or dstdomain in the line printed"
else
 echo "passed"
fi

egrep -v 'dstdomain' $domain_file
if [[ $(echo $?) -ne 1 ]];then
 echo "please add acl or dstdomain in the line printed"
else
 echo "passed"
fi

sleep 2
echo
echo

echo "start to check $ip_file"
egrep -v 'acl' $ip_file
if [[ $(echo $?) -ne 1 ]];then
 echo "please add acl or dst in the line printed"
else
 echo "passed"
fi

egrep -v 'dst' $ip_file
if [[ $(echo $?) -ne 1 ]];then
 echo "please add acl or dst in the line printed"
else
 echo "passed"
fi

sleep 2
echo
echo

echo "start to check $port_file"
egrep -v 'acl' $port_file
if [[ $(echo $?) -ne 1 ]];then
 echo "please add acl or port in the line printed"
else
 echo "passed"
fi

egrep -v 'port' $port_file
if [[ $(echo $?) -ne 1 ]];then
 echo "please add acl or port in the line printed"
else
 echo "passed"
fi

echo
echo
echo "All test is compeleted, please check if anything wrong in the file thanks"

echo "if anything wrong please correct it or contact yi.yao@decathlon.com"
