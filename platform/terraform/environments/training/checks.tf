check "kafka_consumers_reference_known_streams" {
  assert {
    condition = alltrue([
      for consumer in values(local.kafka_consumers) :
      contains(["orders", "inventory", "payments"], consumer.event_hub)
    ])
    error_message = "Every Kafka consumer must reference a known CloudMart Event Hub."
  }
}

check "kafka_group_ids_are_unique" {
  assert {
    condition = (
      length(distinct([
        for consumer in values(local.kafka_consumers) :
        consumer.group_id
      ]))
      ==
      length(local.kafka_consumers)
    )
    error_message = "Kafka group IDs must be unique across different logical CloudMart consumers."
  }
}
