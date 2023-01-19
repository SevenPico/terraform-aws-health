package:
	go mod tidy
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build
	zip -qq lambda.zip lambda
	rm lambda
