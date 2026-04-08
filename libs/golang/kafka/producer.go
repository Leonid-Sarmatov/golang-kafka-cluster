package kafka

import (
	"fmt"
	"log"
	"math/rand"
	"strings"
	"time"

	confluent_kafka "github.com/confluentinc/confluent-kafka-go/v2/kafka"
)

// Функциональная опция
type FuncOptProducer func(producer *KafkaProducer)

// Таймаут подключения к кластеру
func ConnectionTimeout(timeout time.Duration) FuncOptProducer {
	return func(producer *KafkaProducer) {
		producer.connectionTimeout = timeout
	}
}

// Количество попыток подключения
func ConnectionAttempts(attempts int) FuncOptProducer {
	return func(producer *KafkaProducer) {
		producer.connectionAttempts = attempts
	}
}

// exponential backoff with Jitter
func EnableExponentialConnectionWithJitter(jitter time.Duration) FuncOptProducer {
	return func(producer *KafkaProducer) {
		producer.exponentialConnectionEnable = true
		producer.exponentialConnectionJitter = jitter
	}
}

// Добавить bootstrap сервер
func AddBootstrapServer(url string) FuncOptProducer {
	return func(producer *KafkaProducer) {
		producer.bootstrapServers = append(producer.bootstrapServers, url)
	}
}

// Дескриптор для продюсера
type KafkaProducer struct {
	connectionTimeout           time.Duration
	connectionAttempts          int
	exponentialConnectionEnable bool
	exponentialConnectionJitter time.Duration
	bootstrapServers            []string
	producerClient              *confluent_kafka.Producer
}

func NewKafkaProducer(opts ...FuncOptProducer) *KafkaProducer {
	kp := &KafkaProducer{
		connectionTimeout:           1 * time.Second,
		connectionAttempts:          5,
		exponentialConnectionEnable: false,
		exponentialConnectionJitter: 0,
		bootstrapServers:            []string{},
	}

	for _, opt := range opts {
		opt(kp)
	}

	return kp
}

func (kf *KafkaProducer) Init() error {
	var err error
	attempts_counter := 0

	for attempts_counter < kf.connectionAttempts {
		kf.producerClient, err = confluent_kafka.NewProducer(
			&confluent_kafka.ConfigMap{
				"bootstrap.servers": strings.Join(kf.bootstrapServers, ","),
			})

		if err == nil {
			break
		}

		if kf.exponentialConnectionEnable {
			// Реализуем экспоненциальный бэкофф (базовый таймаут + 2^повторение + 1 секунда)
			kf.connectionTimeout += time.Duration(1<<uint(attempts_counter)) * time.Second
			// Добавляем джиттер (разброс от -Jitter/2 до +Jitter/2 ко времени задержки)
			x := kf.connectionTimeout + time.Duration(
				rand.Int63n(int64(kf.exponentialConnectionJitter)*2)-int64(kf.exponentialConnectionJitter))
			log.Printf("Trying to connect to kafka cluster, attempts %d, next timeout %d ns", attempts_counter, kf.connectionTimeout)
			time.Sleep(x)
		} else {
			log.Printf("Trying to connect to kafka cluster, attempts %d, next timeout %d ns", attempts_counter, kf.connectionTimeout)
			time.Sleep(kf.connectionTimeout)
		}

		attempts_counter += 1
	}

	return nil
}

func SimpleExampleProducer(kf *KafkaProducer) {
	go func() {
		for e := range kf.producerClient.Events() {
			switch ev := e.(type) {
			case *confluent_kafka.Message:
				m := ev
				if m.TopicPartition.Error != nil {
					fmt.Printf("Delivery failed: %v\n", m.TopicPartition.Error)
				} else {
					fmt.Printf("Delivered message to topic %s [%d] at offset %v\n",
						*m.TopicPartition.Topic, m.TopicPartition.Partition, m.TopicPartition.Offset)
				}
			case confluent_kafka.Error:
				fmt.Printf("Error: %v\n", ev)
			default:
				fmt.Printf("Ignored event: %s\n", ev)
			}
		}
	}()

	go func() {
		msgcnt := 0

		for {
			value := fmt.Sprintf("Producer example, msgcnt=%d", msgcnt)

			topic := "test"
			err := kf.producerClient.Produce(
				&confluent_kafka.Message{
					TopicPartition: confluent_kafka.TopicPartition{
						Topic:     &topic,
						Partition: confluent_kafka.PartitionAny,
					},
					Value:   []byte(value),
					Headers: []confluent_kafka.Header{{Key: "myTestHeader", Value: []byte("header values are binary")}},
				},
				nil,
			)

			if err != nil {
				if err.(confluent_kafka.Error).Code() == confluent_kafka.ErrQueueFull {
					time.Sleep(time.Second)
					continue
				}
				fmt.Printf("Failed to produce message: %v\n", err)
			}

			time.Sleep(time.Second)
			msgcnt++
		}
	}()
}
