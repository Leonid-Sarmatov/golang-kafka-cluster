package main

import (
	"time"

	//kafka "github.com/confluentinc/confluent-kafka-go/v2/kafka"
	kafka "kafka_cluster/libs/golang/kafka"
)

func main() {

	// time.Sleep(5 * time.Second)

	// bootstrapServers := "kafka-server-alpha:9092"
	// topic := "test"
	// //totalMsgcnt := 3

	// p, err := kafka.NewProducer(&kafka.ConfigMap{"bootstrap.servers": bootstrapServers})

	// if err != nil {
	// 	fmt.Printf("Failed to create producer: %s\n", err)
	// 	os.Exit(1)
	// }

	// fmt.Printf("Created Producer %v\n", p)

	// go func() {
	// 	for e := range p.Events() {
	// 		switch ev := e.(type) {
	// 		case *kafka.Message:
	// 			m := ev
	// 			if m.TopicPartition.Error != nil {
	// 				fmt.Printf("Delivery failed: %v\n", m.TopicPartition.Error)
	// 			} else {
	// 				fmt.Printf("Delivered message to topic %s [%d] at offset %v\n",
	// 					*m.TopicPartition.Topic, m.TopicPartition.Partition, m.TopicPartition.Offset)
	// 			}
	// 		case kafka.Error:
	// 			fmt.Printf("Error: %v\n", ev)
	// 		default:
	// 			fmt.Printf("Ignored event: %s\n", ev)
	// 		}
	// 	}
	// }()

	// msgcnt := 0
	// for {
	// 	value := fmt.Sprintf("Producer example, message #%d", msgcnt)

	// 	err = p.Produce(&kafka.Message{
	// 		TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
	// 		Value:          []byte(value),
	// 		Headers:        []kafka.Header{{Key: "myTestHeader", Value: []byte("header values are binary")}},
	// 	}, nil)

	// 	if err != nil {
	// 		if err.(kafka.Error).Code() == kafka.ErrQueueFull {
	// 			time.Sleep(time.Second)
	// 			continue
	// 		}
	// 		fmt.Printf("Failed to produce message: %v\n", err)
	// 	}
	// 	time.Sleep(time.Second)
	// 	msgcnt++
	// }

	// for p.Flush(10000) > 0 {
	// 	fmt.Print("Still waiting to flush outstanding messages\n")
	// }
	// p.Close()

	p := kafka.NewKafkaProducer(
		kafka.ConnectionAttempts(10),
		kafka.EnableExponentialConnectionWithJitter(500*time.Millisecond),
		kafka.ConnectionTimeout(1*time.Second),
		kafka.AddBootstrapServer("kafka-server-alpha:9092"),
	)

	err := p.Init()
	if err != nil {
		panic(err)
	}

	kafka.SimpleExampleProducer(p)

	for {
	}
}
