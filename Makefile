dir=$(shell pwd)
docker_dir=$(dir)

migrate:
	docker-compose --project-directory $(docker_dir) run --rm db-migrator   

service-env: validate-service
	cat docker-compose.yaml | yq e '.services.$(service).env_file' | sed 's/-\ \.\/config\///g' | xargs -I {} cat ./config/{} ; echo

prepare-images:
	docker-compose --project-directory $(docker_dir) pull; make build-images

init-start:
	make prepare-images; make start;

image: validate-service
	 docker-compose --project-directory $(docker_dir) build $(service) 

images:
	yq e '.services | keys' $(docker_dir)/docker-compose.yaml | sed 's/-//' | xargs -I {} docker-compose --project-directory $(docker_dir) build {} 

up:
	make start 

start:
	make migrate; docker-compose --project-directory $(docker_dir) up -d $(service) 

build-restart: validate-service
	make image service=$(service) && make start service=$(service)  

quick-deploy-all:
	make quick-deploy service='api public-ui admin-ui db-migrator'

quick-deploy: validate-service
	. ${dir}/.env; /bin/sh ${dir}/.bin/deploy.sh "${service}"

# validation rules
validate-service:
ifndef service
	$(error service is required. syntax: make <command> service=<service_name>)
endif