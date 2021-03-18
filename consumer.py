from kafka import KafkaConsumer

consumer = KafkaConsumer(
    "jason_test",
    bootstrap_servers = [
        "kafka-aks-broker.pp.dktapp.cloud:9094"
    ]
)
for each in consumer:
    print("%s:%d:%d: key=%s value=%s"%(
        each.topic, each.partition,
        each.offset, each.key, each.value
    ))
