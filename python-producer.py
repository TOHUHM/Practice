import json
import time
from kafka import KafkaProducer
from kafka.errors import KafkaError
from kafka.future import log
localtime = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
if __name__ == "__main__":
  producer = KafkaProducer(bootstrap_servers='kafka-aks-broker.pp.dktapp.cloud:9094')

future = producer.send('jason_test2', b"ticks")

try:
    record_metadata = future.get( timeout=10)
except KafkaError :
    log.exeption()
    pass

print( record_metadata.topic)
print(record_metadata.partition)
print(record_metadata.offset)


for _ in range (100):
    producer.send('jason_test2', time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()))
    producer.send('jason_test2', time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()))
    producer.send('jason_test2', time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()))
    producer.send('jason_test2', time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()))
    producer.send('jason_test2', time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()))
    time.sleep(1)
