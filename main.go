package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/google/uuid"
	"log"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
)

var tableName = "Contacts-FernandoAvila"

func HandleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Printf("HandleRequest Go")
	var contact Contact
	if err := json.Unmarshal([]byte(request.Body), &contact); err != nil {
		log.Printf("Parse error: %v", err)
		return events.APIGatewayProxyResponse{
			StatusCode: 400,
			Body:       "Bad request",
		}, nil
	}

	if strings.TrimSpace(contact.FirstName) == "" || strings.TrimSpace(contact.LastName) == "" {
		log.Printf("The first and last name fields cannot be empty.")
		return events.APIGatewayProxyResponse{
			StatusCode: 400,
			Body:       "The first and last name fields cannot be empty.",
		}, nil
	}

	sess := session.Must(session.NewSession())
	svc := dynamodb.New(sess)

	contact.ID = uuid.New().String()

	item := map[string]*dynamodb.AttributeValue{
		"id":        {S: aws.String(contact.ID)},
		"firstName": {S: aws.String(contact.FirstName)},
		"lastName":  {S: aws.String(contact.LastName)},
		"status":    {S: aws.String("CREATED")},
	}

	input := &dynamodb.PutItemInput{
		Item:      item,
		TableName: aws.String(tableName),
	}

	_, err := svc.PutItem(input)
	if err != nil {
		log.Printf("DB Error: %v", err)
		return events.APIGatewayProxyResponse{StatusCode: 500}, nil
	}

	response := fmt.Sprintf("Contact with ID: %s was successfully saved", contact.ID)
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       response,
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}

type Contact struct {
	ID        string `json:"id"`
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
}
