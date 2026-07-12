.PHONY: provision

# -------------------------------------------------------------------
# provision — Run the Ansible playbook locally
#
# -K prompts for the sudo password (omit if you have passwordless sudo)
# -------------------------------------------------------------------
provision:
	@echo "=========================================="
	@echo "  Running Ansible playbook locally"
	@echo "=========================================="
	ansible-playbook playbooks/site.yml -K
