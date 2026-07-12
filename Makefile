CONTAINER_NAME := llm-provision-test
EXEC_USER     := localuser

# Auto-detect podman or docker
DOCKER_EXECUTABLE := $(shell command -v podman 2>/dev/null || command -v docker 2>/dev/null || echo docker)

# Select Dockerfile and image name based on LLM_PROVISION_TEST_CACHED (default: 1)
ifeq ($(LLM_PROVISION_TEST_CACHED),0)
  DOCKERFILE := test/Dockerfile.llm-provision-test
  IMAGE_NAME := llm-provision-test-bare
else
  DOCKERFILE := test/Dockerfile.llm-provision-test-cached
  IMAGE_NAME := llm-provision-test-cached
endif

.PHONY: test test_local bash build clean

# -------------------------------------------------------------------
# test       — Build the container and provision from GitHub
# -------------------------------------------------------------------
test: build
	@echo "=========================================="
	@echo "  Provisioning from GitHub"
	@echo "=========================================="
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
	@echo "=========================================="
	@echo "  Provisioning from local mount"
	@echo "=========================================="
	$(DOCKER_EXECUTABLE) rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	$(DOCKER_EXECUTABLE) run --rm \
		--privileged \
		--user "$(EXEC_USER)" \
		--name "$(CONTAINER_NAME)" \
		-v "$(PWD):/home/$(EXEC_USER)/repos/llm-provision" \
		"$(IMAGE_NAME)" \
		bash -c "bash /home/$(EXEC_USER)/repos/llm-provision/init.sh"

# -------------------------------------------------------------------
# bash       — Open an interactive shell in the container
# -------------------------------------------------------------------
bash: build
	@echo "=========================================="
	@echo "  Opening interactive shell"
	@echo "=========================================="
	$(DOCKER_EXECUTABLE) run --rm -it \
		--privileged \
		--user "$(EXEC_USER)" \
		--name "$(CONTAINER_NAME)" \
		-v "$(PWD):/home/$(EXEC_USER)/repos/llm-provision" \
		"$(IMAGE_NAME)" \
		bash

# -------------------------------------------------------------------
# build      — Build the test container image
# -------------------------------------------------------------------
build:
	@echo "=========================================="
	@echo "  Building container image: $(IMAGE_NAME)"
	@echo "  Dockerfile: $(DOCKERFILE)"
	@echo "=========================================="
	$(DOCKER_EXECUTABLE) build -t "$(IMAGE_NAME)" -f "$(DOCKERFILE)" .

# -------------------------------------------------------------------
# clean      — Remove the test container and image
# -------------------------------------------------------------------
clean:
	@echo "Removing container and image..."
	$(DOCKER_EXECUTABLE) rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	$(DOCKER_EXECUTABLE) rmi "$(IMAGE_NAME)" 2>/dev/null || true
	@echo "Done."
