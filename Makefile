CONTAINER_NAME       := llm-provision-test
SERVER_CONTAINER_NAME := llm-provision-server
EXEC_USER            := localuser

# Auto-detect podman or docker
DOCKER_EXECUTABLE := $(shell command -v podman 2>/dev/null || command -v docker 2>/dev/null || echo docker)

# Image names
BASE_IMAGE     := llm-provision-test
CACHED_IMAGE   := llm-provision-test-cached

# Select target based on LLM_PROVISION_TEST_CACHED (default: 1)
ifeq ($(LLM_PROVISION_TEST_CACHED),0)
  IMAGE_NAME := $(BASE_IMAGE)
else
  IMAGE_NAME := $(CACHED_IMAGE)
endif

.PHONY: test test_local server_local test_server bash build build-base build-cached clean

# -------------------------------------------------------------------
# test       — Build the container and provision from GitHub
# -------------------------------------------------------------------
test: build
	@echo "========================================"
	@echo "  Makefile: Provisioning from GitHub"
	@echo "========================================"
	$(DOCKER_EXECUTABLE) rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	$(DOCKER_EXECUTABLE) run --rm \
		--privileged \
		--user "$(EXEC_USER)" \
		--name "$(CONTAINER_NAME)" \
		"$(IMAGE_NAME)" \
		bash -c "curl -fsSL https://raw.githubusercontent.com/lfendy-llm/llm-provision/refs/heads/main/init.sh | sudo bash"

# -------------------------------------------------------------------
# test_local — Build the container, mount local repo, run init.sh
#              (clone step auto-skips because repo is mounted)
# -------------------------------------------------------------------
test_local: build
	@echo "========================================"
	@echo "  Makefile: Provisioning from local mount"
	@echo "========================================"
	$(DOCKER_EXECUTABLE) rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	$(DOCKER_EXECUTABLE) run --rm \
		--privileged \
		--user "$(EXEC_USER)" \
		--name "$(CONTAINER_NAME)" \
		-v "$(PWD):/home/$(EXEC_USER)/repos/llm-provision" \
		"$(IMAGE_NAME)" \
		bash -c "bash /home/$(EXEC_USER)/repos/llm-provision/init.sh"

# -------------------------------------------------------------------
# server_local — Start a detached container with the repo mounted
#                (like a live server you can exec into)
# -------------------------------------------------------------------
server_local: build
	@echo "========================================"
	@echo "  Makefile: Starting server container"
	@echo "========================================"
	$(DOCKER_EXECUTABLE) rm -f "$(SERVER_CONTAINER_NAME)" 2>/dev/null || true
	$(DOCKER_EXECUTABLE) run -d \
		--privileged \
		--user "$(EXEC_USER)" \
		--name "$(SERVER_CONTAINER_NAME)" \
		-v "$(PWD):/home/$(EXEC_USER)/repos/llm-provision" \
		"$(IMAGE_NAME)" \
		sleep infinity
	@echo "Container $(SERVER_CONTAINER_NAME) is running."
	@echo "  Exec into it:  $(DOCKER_EXECUTABLE) exec -it $(SERVER_CONTAINER_NAME) bash"

# -------------------------------------------------------------------
# test_server — Run init.sh inside the running server container
# -------------------------------------------------------------------
test_server:
	@echo "========================================"
	@echo "  Makefile: Provisioning server container"
	@echo "========================================"
	$(DOCKER_EXECUTABLE) exec $(SERVER_CONTAINER_NAME) bash -c "bash /home/$(EXEC_USER)/repos/llm-provision/init.sh"

# -------------------------------------------------------------------
# bash       — Open an interactive shell in the container
# -------------------------------------------------------------------
bash: build
	@echo "========================================"
	@echo "  Makefile: Opening interactive shell"
	@echo "========================================"
	$(DOCKER_EXECUTABLE) run --rm -it \
		--privileged \
		--user "$(EXEC_USER)" \
		--name "$(CONTAINER_NAME)" \
		-v "$(PWD):/home/$(EXEC_USER)/repos/llm-provision" \
		"$(IMAGE_NAME)" \
		bash

# -------------------------------------------------------------------
# build      — Build the selected image
# -------------------------------------------------------------------
ifeq ($(LLM_PROVISION_TEST_CACHED),0)
build: build-base
else
build: build-cached
endif

# -------------------------------------------------------------------
# build-base  — Build the base image
# -------------------------------------------------------------------
build-base:
	@echo "========================================"
	@echo "  Makefile: Building $(BASE_IMAGE)"
	@echo "  Dockerfile: test/Dockerfile.$(BASE_IMAGE)"
	@echo "========================================"
	$(DOCKER_EXECUTABLE) build -t "$(BASE_IMAGE)" -f "test/Dockerfile.$(BASE_IMAGE)" .

# -------------------------------------------------------------------
# build-cached — Build the cached image (depends on base)
# -------------------------------------------------------------------
build-cached: build-base
	@echo "========================================"
	@echo "  Makefile: Building $(CACHED_IMAGE)"
	@echo "  Dockerfile: test/Dockerfile.$(CACHED_IMAGE)"
	@echo "========================================"
	$(DOCKER_EXECUTABLE) build -t "$(CACHED_IMAGE)" -f "test/Dockerfile.$(CACHED_IMAGE)" .

# -------------------------------------------------------------------
# clean      — Remove the test container and images
# -------------------------------------------------------------------
clean:
	@echo "Makefile: Removing container and images..."
	$(DOCKER_EXECUTABLE) rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	$(DOCKER_EXECUTABLE) rm -f "$(SERVER_CONTAINER_NAME)" 2>/dev/null || true
	$(DOCKER_EXECUTABLE) rmi "$(BASE_IMAGE)" 2>/dev/null || true
	$(DOCKER_EXECUTABLE) rmi "$(CACHED_IMAGE)" 2>/dev/null || true
	@echo "Makefile: Done."
