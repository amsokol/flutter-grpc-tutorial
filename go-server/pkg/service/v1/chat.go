package v1

import (
	"context"
	"fmt"
	"log"

	// "github.com/golang/protobuf/ptypes"
	"github.com/golang/protobuf/ptypes/empty"
	"github.com/golang/protobuf/ptypes/wrappers"

	"github.com/amsokol/flutter-grpc-tutorial/go-server/pkg/api/v1"
)

// chatServiceServer is implementation of v1.ChatServiceServer proto interface
type chatServiceServer struct {
	msg chan string
}

// NewChatServiceServer creates Chat service
func NewChatServiceServer() v1.ChatServiceServer {
	return &chatServiceServer{msg: make(chan string)}
}

// Send is sync method example
func (s *chatServiceServer) Send(ctx context.Context, message *wrappers.StringValue) (*empty.Empty, error) {
	if message != nil {
		log.Printf("Send requested: message=%v", *message)
		s.msg <- message.Value
	} else {
		log.Print("Send requested: message=<empty>")
	}

	return &empty.Empty{}, nil
}

// Subscribe is streaming method example: server responds once a minute
func (s *chatServiceServer) Subscribe(e *empty.Empty, stream v1.ChatService_SubscribeServer) error {
	log.Print("Subscribe requested")
	for {
		m := <-s.msg
		n := v1.Notification{Message: fmt.Sprintf("I received: %s", m)}
		if err := stream.Send(&n); err != nil {
			log.Printf("Stream connection failed: %v", err)
			return nil
		}
		log.Printf("Message sent: %+v", n)
	}
}

/*
// Subscribe is streaming method example: server responds once a minute
func (s *chatServiceServer) Subscribe(e *empty.Empty, stream v1.ChatService_SubscribeServer) error {
	log.Print("Subscribe requested")
	i := 1
	for {
		t := time.Now().Format(time.RFC3339)
		m := fmt.Sprintf("Notification #%d from server: local time is %s", i, t)
		n := v1.Notification{Message: m}
		if err := stream.Send(&n); err != nil {
			log.Printf("Stream connection failed: %v", err)
			return nil
		}
		log.Printf("Subscribe sent: %+v", n)
		log.Print("Sleep for 1 minute")
		time.Sleep(time.Second * 10)
		i++
	}
}
*/
