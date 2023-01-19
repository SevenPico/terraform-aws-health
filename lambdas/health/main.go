package main

import (
	"context"
	"encoding/json"
	"lambda/health"
	"lambda/widgets"

	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(router)
}

type LambdaRequest struct {
	health.Request
	widgets.HttpHealthRequest
	widgets.CicdHealthRequest
}

func router(ctx context.Context, request LambdaRequest) (string, error) {
	//pretty.Println(request)

	var h health.Health
	var err error

	switch request.Kind {
	case "cicd":
		h, err = widgets.NewCicdHealth(ctx, request.CicdHealthRequest, request.WidgetContext)
	case "http":
		h, err = widgets.NewHttpHealth(ctx, request.HttpHealthRequest)
	default:
		return "Unimplemented kind: " + request.Kind, nil
	}

	if err != nil {
		return "", err
	}

	if request.Mode == "html" {
		return h.Html(), nil
	} else {
		b, err := json.MarshalIndent(&h, "", "\t")
		return string(b), err
	}
}
