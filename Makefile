mkfile_path:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

DEFAULT_GOAL := help

##@ [Targets]
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

## build: builds all binaries
build: clean build_front build_back
	@printf "All binaries built!\n"

## clean: cleans all binaries and runs go clean
clean:
	@echo "Cleaning..."
	@rm -f ./dist/*
	@go clean
	@echo "Cleaned!"

## build_front: builds the front end
build_front:
	@echo "Building front end..."
	@go build -o ./dist/client ./client/
	@echo "Front end built!"

## build_back: builds the back end
build_back:
	@echo "Building back end..."
	@go build -o ./dist/server-cors ./server/server-cors.go
	@go build -o ./dist/server-no-cors ./server/server-no-cors.go
	@echo "Back ends built!"

## start: starts front and back end
start: start_back start_front
	@echo "All applications started"
	
## start_front: starts the front end
start_front: build_front
	@echo "Starting the front end..."
	@./dist/client &
	@echo "Front end running!"

## start_back: starts the back end
start_back: build_back
	@echo "Starting the back ends..."
	@./dist/server-cors &
	@./dist/server-no-cors &
	@echo "Back ends running!"

## stop: stops the front and back end
stop: stop_front stop_back
	@echo "All applications stopped"

## stop_front: stops the front end
stop_front:
	@echo "Stopping the front end..."
	@-pkill -SIGTERM -f "client"
	@echo "Stopped front end"

## stop_back: stops the back end
stop_back:
	@echo "Stopping the back end..."
	@-pkill -SIGTERM -f "server-cors"
	@-pkill -SIGTERM -f "server-no-cors"
	@echo "Stopped back ends"

## restart: restarts the front and back end
restart: stop start

.PHONY: build clean build_front build_back start start_front start_back stop stop_front stop_back
