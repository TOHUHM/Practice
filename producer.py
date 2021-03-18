"producer.py"
from kafka import KafkaProducer
from kafka.errors import KafkaError

producer = KafkaProducer(
    bootstrap_servers = ["kafka-aks-broker.pp.dktapp.cloud:9094"]
)

future = producer.send("123123", b"this is a python to kafka")
try:
    record = future.get(timeout=10)
    print(record)
except KafkaError as e:
    print(e)


import 