package:
	go mod tidy
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build
	mv lambda bootstrap
	zip -qq lambda.zip bootstrap
	rm bootstrap
