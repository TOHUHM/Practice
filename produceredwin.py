"producer.py"
from kafka import KafkaProducer
from kafka.errors import KafkaError

producer = KafkaProducer(
    bootstrap_servers = ["de-kafka.dktapp.cloud:9092"]
)

future = producer.send("edwin", b"this is a python to kafka test")
try:
    record = future.get(timeout=10)
    print(record)
except KafkaError as e:
    print(e)
