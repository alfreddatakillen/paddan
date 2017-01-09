# Etherpad docker

## Run it like this

	docker build . -t paddan
	mkdir -p data
	docker run -p 9001:9001 -v data:/data paddan

