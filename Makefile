CONTAINER_NAME := llm-provision-test
EXEC_USER     := localuser

# Auto-detect podman or docker
DOCKER_EXECUTABLE := $(shell command -v podman 2>/dev/null || command -v docker 2>/dev/null || echo docker)

# Select Dockerfile and image name based on LLM_PROVISION_TEST_CACHED (default: 1)
override DOCKERFILE := $(shell \
  if [ "$(LLM_PROVISION_TEST_CACHED)" = "0" ]; then \
    echo test/Dockerfile; \
  else \
    echo test/Dockerfile.cached_init; \
  fi)

override IMAGE_NAME := $(shell \
  if [ "$(LLM_PROVISION_TEST_CACHED)" = "0" ]; then \
    echo llm-provision-test-bare; \
  else \
    echo llm-provision-test-cached; \
  fi)

.PHONY: test test_local build clean

# -------------------------------------------------------------------
# test       — Build the container and provision from GitHub
# -------------------------------------------------------------------
test: build
	@echo "=========================================="
	@echo "  Starting container and provisioning from GitHub"
	@echo "=========================================="
	$(DOCKER_EXECUTABLE) rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	$(DOCKER_EXECUTABLE) run -d \
		--privileged \
		--name "$(CONTAINER_NAME)" \
		"$(IMAGE_NAME)"
	@sleep 2  # give systemd a moment to boot
	@echo ""
	@echo "--- Running init.sh from GitHub ---"
	$(DOCKER_EXECUTABLE) exec --user "$(EXEC_USER)" "$(CONTAINER_NAME)" \
		bash -c "curl -fsSL https://raw.githubusercontent.com/lfendy-llm/llm-provision/refs/heads/main/init.sh | bash"
	@echo ""
	@echo "--- Cleaning up container ---"
	$(DOCKER_EXECUTABLE) rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	@echo "=========================================="
	@echo "  Done."
	@echo "=========================================="

# -------------------------------------------------------------------
# test_local — Build the container, mount local repo, run init.sh
#              (clone step auto-skips because repo is mounted)
# -------------------------------------------------------------------
test_local: build
	@echo "=========================================="
	@echo "  Starting container with local mount"
	@echo "=========================================="
	$(DOCKER_EXECUTABLE) rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	$(DOCKER_EXECUTABLE) run -d \
		--privileged \
		--name "$(CONTAINER_NAME)" \
		-v "$(PWD):/home/$(EXEC_USER)/repos/llm-provision" \
		"$(IMAGE_NAME)"
	@sleep 2
	@echo ""
	@echo "--- Running init.sh from the mounted volume ---"
	$(DOCKER_EXECUTABLE) exec --user "$(EXEC_USER)" "$(CONTAINER_NAME)" \
		bash /home/$(EXEC_USER)/repos/llm-provision/init.sh
	@echo ""
	@echo "--- Cleaning up container ---"
	$(DOCKER_EXECUTABLE) rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	@echo "=========================================="
	@echo "  Done."
	@echo "=========================================="

# -------------------------------------------------------------------
# build      — Build the test container image
# -------------------------------------------------------------------
build:
	@echo "=========================================="
	@echo "  Building container image: $(IMAGE_NAME)"
	@echo "  Dockerfile: $(DOCKERFILE)"
	@echo "=========================================="
	$(DOCKER_EXECUTABLE) build -t "$(IMAGE_NAME)" -f "$(DOCKERFILE)" ./test

# -------------------------------------------------------------------
# clean      — Remove the test container and image
# -------------------------------------------------------------------
clean:
	@echo "Removing container and image..."
	$(DOCKER_EXECUTABLE) rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	$(DOCKER_EXECUTABLE) rmi "$(IMAGE_NAME)" 2>/dev/null || true
	@echo "Done."
