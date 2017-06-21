define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

IMAGE = $(shell basename `pwd`)

help:	## Prints this help
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)


build:	## Builds image
	@docker build -t $(IMAGE) .

rund:
	@docker run \
		--cap-add SYS_ADMIN \
		--cap-add NET_ADMIN \
		-p 5901:5901 -p 2222:2222 -v $$(pwd):/root/shared -d $(IMAGE)  > .container

run: rund ## Runs container
	@echo "Started container $$(cat .container). Ctrl-C to stop showing logs."
	@-$(MAKE) logs

start: run ## Runs container

is_running:
	@test -f .container || exit 1
	@-docker ps --filter id=$$(cat .container) 2>/dev/null

rm:	## Removes container (but not image)
	@docker rm $(IMAGE)

logs:	## Shows logs
	@docker logs -f $$(cat .container)

stop:  ## Stops container
	@echo "Stopping container..."
	@docker stop $$(cat .container) && rm .container

ps:
	@-test -f .container && \
		docker ps --filter id=$$(cat .container) \
		|| echo "Detenido"

supervisorctl:
	@docker exec -ti $$(cat .container) supervisorctl

shell: ## Runs shell
	@test -f .container && \
		docker exec -ti $$(cat .container) bash

killall:	## If something went wrong, use this
	@-docker ps --format '{{.ID}}' --filter name=$(IMAGE_NAME) | xargs docker stop
	@rm -rf .container

localtag:
	true

cmdline:  ## Use to run some command inside the image (new container)
	@echo "# \$$(make cmdline) command\n" >/dev/stderr
	@-echo "docker run --rm $(IMAGE)"

get_pubkey:
	docker exec $$(cat .container) cat /root/.ssh/id_rsa.pub

get_authkeys:
	docker exec $$(cat .container) cat /root/.ssh/authorized_keys

core-gui:

	docker exec $$(cat .container) cat /root/.ssh/id_rsa.pub | \
		ssh -vvv -i /dev/stdin -p 2222 -X root@localhost core-gui

ports: is_running ## Show ports bindings
	@docker port $$(cat .container)
