.PHONY: bootstrap provision

# -------------------------------------------------------------------
# bootstrap — Run the bootstrap playbook (root: apt, user creation)
# -------------------------------------------------------------------
bootstrap:
	@echo "=========================================="
	@echo "  Makefile: Running bootstrap playbook"
	@echo "=========================================="
	ansible-playbook playbooks/bootstrap.yml $(ANSIBLE_ARGS)

# -------------------------------------------------------------------
# provision — Run the devuser provisioning playbook
# -------------------------------------------------------------------
provision:
	@echo "=========================================="
	@echo "  Makefile: Running provision playbook (devuser)"
	@echo "=========================================="
	ansible-playbook playbooks/provision.yml $(ANSIBLE_ARGS)
