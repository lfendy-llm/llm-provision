.PHONY: provision

# -------------------------------------------------------------------
# provision — Run the Ansible playbook locally
#
# Sudo is handled by the playbook's become: yes setting.
# If your user requires a password for sudo, run with -K:
#   make provision ANSIBLE_ARGS="-K"
# -------------------------------------------------------------------
provision:
	@echo "=========================================="
	@echo "  Running Ansible playbook locally"
	@echo "=========================================="
	ansible-playbook playbooks/site.yml $(ANSIBLE_ARGS)
