#include <stdio.h>
#include <librdkafka/rdkafka.h>

void print_version() {
    setbuf(stdout, NULL);
    printf("[C]: librdkafka version: %s\n", rd_kafka_version_str());
}