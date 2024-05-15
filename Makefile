include .env.default
include .env

help:
	@echo "run:" 2>& 
	@echo "	- install" 2>& 
	@echo "	- docker-build" 2>& 
	@echo "	- tox" 2>& 

install:
	pdm sync

docker-build:
	docker compose build -f docker/docker-compose.yaml

tox:
	pdm run tox -e prospector
