dir=$(shell pwd)
docker_dir=$(dir)
docker_file = $(docker_dir)/docker-compose.yaml
docker_override_file = $(docker_dir)/docker-compose.override.yaml
service_repo=$(shell cat $(docker_file) | yq e '.services.$(service).image' | cut -f1 -d":")
escaped_service_repo=$(shell echo $(service_repo) | sed 's/\//\\\//g')

migration: validate-command
	docker compose --project-directory $(docker_dir) run --rm migrator make $(cmd)

migrate:
	docker compose --project-directory $(docker_dir) run --rm migrator   

ci-migration: 
	make pull-service-tag service=migrator && make migration

set-service-tag: validate-tag
	sed -i 's/$(escaped_service_repo):.\+$$/$(escaped_service_repo):$(tag)/g' $(docker_override_file)

pull-service-tag: set-service-tag
	docker compose --project-directory $(docker_dir) pull $(service)

deploy-service-tag: pull-service-tag
	make start && make docker-cleanup

docker-cleanup:
	# docker images --filter 'dangling=true' -q --no-trunc | xargs -r docker rmi
	docker image prune -af

get-env: validate-service
	cat $(docker_file) | yq e '.services.$(service).env_file' | sed 's/-\ \.\/config\///g' | xargs -I {} cat $(docker_dir)/config/{} ; echo | egrep -v '^#|^$$' 

up:
	make start 

start:
	docker compose --project-directory $(docker_dir) up -d $(service) 

# validation rules
validate-service:
ifndef service
	$(error service is required. syntax: make <command> service=<service_name>)
endif

validate-tag:
ifndef tag
	$(error tag is required. syntax: make <command> tag=<1223>)
endif

validate-version:
ifndef version
	$(error version is required. syntax: make <command> version=<1223>)
endif

validate-command:
ifndef cmd
	$(error command is required. syntax: make <command> cmd=<up>)
endif
