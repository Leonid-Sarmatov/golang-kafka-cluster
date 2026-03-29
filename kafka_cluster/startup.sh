#!/bin/bash
DATA_DIR="/data/kafka"
CONFIG="/opt/kafka/config/server.properties"
CLUSTER_ID="G_3ws2gtSqKZVfPl2LgSYA"

echo "Kafka startup script..."

if [ -s "$DATA_DIR/meta.properties" ]; then
  echo "✓ meta.properties exists"
else
  echo "Creating meta.properties..."
  chown -R 1000:1000 "$DATA_DIR"

  /opt/kafka/bin/kafka-storage.sh format \
    --ignore-formatted \
    --cluster-id "$CLUSTER_ID" \
    --config "$CONFIG"

  echo "✓ meta.properties created"
fi

echo "Starting Kafka..."

exec /opt/kafka/bin/kafka-server-start.sh "$CONFIG"

