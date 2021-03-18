#!/bin/bash
# firstly, find out the topic which replications !=3
#then run below script to generate partition Infr


brokerids="0,1,2"   #brokers ID
topics=`cat /bitnami/kafka/data/topic.txt`   #path of topic without 3 repilication


while read -r line; do lines+=("$line"); done <<<"$topics"
echo '{"version":1,
  "partitions":['
for t in $topics; do
    sep=","
    pcount=$(kafka-topics.sh --describe --zookeeper zookeeper:2181 --topic $t | awk '{print $2}' | uniq -c |awk 'NR==2{print $1}')
    for i in $(seq 0 $[pcount - 1]); do
        if [ "${t}" == "${lines[-1]}" ] && [ "$[pcount - 1]" == "$i" ]; then sep=""; fi
        randombrokers=$(echo "$brokerids" | sed -r 's/,/ /g' | tr " " "\n" | shuf | tr  "\n" "," | head -c -1)
        echo "    {\"topic\":\"${t}\",\"partition\":${i},\"replicas\":[${randombrokers}]}$sep" >> /bitnami/kafka/data/increase.json
    done
done

echo '  ]
}' >> /bitnami/kafka/data/increase.json


#!/bin/bash

echo "start to change the repilication factor"

unset JMX_PORT
unset KAFKA_JMX_OPTS

kafka-reassign-partitions.sh --zookeeper zookeeper:2181 --reassignment-json-file /bitnami/kafka/data/increase.json --execute &>/tmp/addfactor.log
