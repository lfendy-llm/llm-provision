IMAGE_NAME   := llm-provision-test-image
CONTAINER_NAME := llm-provision-test
EXEC_USER    := localuser

.PHONY: test test_local clean

# -------------------------------------------------------------------
# test       — Build the podman container and provision from GitHub
# -------------------------------------------------------------------
test: build
	@echo "=========================================="
	@echo "  Starting container and provisioning from GitHub"
	@echo "=========================================="
	podman rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	podman run -d \
		--privileged \
		--name "$(CONTAINER_NAME)" \
		"$(IMAGE_NAME)"
	@sleep 2  # give systemd a moment to boot
	@echo ""
	@echo "--- Running pull.sh from GitHub (includes init.sh) ---"
	podman exec --user "$(EXEC_USER)" "$(CONTAINER_NAME)" \
		bash -c "curl -fsSL https://raw.githubusercontent.com/lfendy-llm/llm-provision/refs/heads/main/pull.sh | bash"
	@echo ""
	@echo "=========================================="
	@echo "  Done. Container is running."
	@echo "  Connect: podman exec -it --user $(EXEC_USER) $(CONTAINER_NAME) bash"
	@echo "=========================================="

# -------------------------------------------------------------------
# test_local — Build the container, mount local repo, run init.sh
#              (skips pull.sh because the repo is mounted directly)
# -------------------------------------------------------------------
test_local: build
	@echo "=========================================="
	@echo "  Starting container with local mount"
	@echo "=========================================="
	podman rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	podman run -d \
		--privileged \
		--name "$(CONTAINER_NAME)" \
		-v "$(PWD):/home/$(EXEC_USER)/repos/llm-provision" \
		"$(IMAGE_NAME)"
	@sleep 2
	@echo ""
	@echo "--- Running init.sh from the mounted volume (skipping pull.sh) ---"
	podman exec --user "$(EXEC_USER)" "$(CONTAINER_NAME)" \
		bash /home/$(EXEC_USER)/repos/llm-provision/init.sh
	@echo ""
	@echo "=========================================="
	@echo "  Done. Local repo mounted at /home/$(EXEC_USER)/repos/llm-provision"
	@echo "  Connect: podman exec -it --user $(EXEC_USER) $(CONTAINER_NAME) bash"
	@echo "=========================================="

# -------------------------------------------------------------------
# build      — Build the test podman image
# -------------------------------------------------------------------
build:
	@echo "=========================================="
	@echo "  Building podman image: $(IMAGE_NAME)"
	@echo "=========================================="
	podman build -t "$(IMAGE_NAME)" ./test

# -------------------------------------------------------------------
# clean      — Remove the test container and image
# -------------------------------------------------------------------
clean:
	@echo "Removing container and image..."
	podman rm -f "$(CONTAINER_NAME)" 2>/dev/null || true
	podman rmi "$(IMAGE_NAME)" 2>/dev/null || true
	@echo "Done."
