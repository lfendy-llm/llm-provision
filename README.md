# llm-provision

Bootstrap and provision a fresh **Ubuntu 26.04** Server with Ansible — installs CLI tools, Podman, pi coding agent, SSH, a lightweight GUI, and dotfiles.

## Quickstart

```bash
# Run directly on a fresh Ubuntu server
curl -fsSL https://raw.githubusercontent.com/lfendy-llm/llm-provision/refs/heads/main/init.sh | sudo bash
```

Or clone and run locally:

```bash
git clone https://github.com/lfendy-llm/llm-provision.git ~/repos/llm-provision
cd ~/repos/llm-provision
sudo bash init.sh
```

## What it does

`init.sh` runs three steps:

1. **Install dependencies** — `apt update && apt upgrade`, then installs `git`, `make`, and `ansible`
2. **Clone the repo** (if not already present) to `~/repos/llm-provision`
3. **Run Ansible playbooks** — `make bootstrap` then `make provision`

### Bootstrap playbook (`make bootstrap`)

Creates the `devuser` account and prepares the system:

| Task | Details |
|---|---|
| `apt dist-upgrade` | System packages up-to-date, autoremove enabled |
| Install `zsh` | Shell for devuser |
| Create `devuser` | Passwordless sudo, zsh shell |

### Provision playbook (`make provision`)

Configures everything as `devuser`:

| Task | Details |
|---|---|
| **CLI tools** | `net-tools`, `tmux`, `vim`, `fzf`, `fd-find`, `ripgrep` |
| **Oh My Zsh** | Unattended install for devuser |
| **Podman** | `podman` + `podman-compose` (no docker alias) |
| **Node.js 22.x** | Via NodeSource (if missing or outdated) |
| **pi coding agent** | `@earendil-works/pi-coding-agent` installed globally |
| **pi packages** | `pi-web-agent`, `pi-cost-counter`, `pi-deepseek-optimized`, `pi-patty-bg-tasks` |
| **models.json** | Deploys pre-configured providers/models to `~/.pi/agent/models.json` |
| **SSH** | `openssh-server`, key-only auth, authorized_keys deployed |
| **GUI** | `xorg`, `openbox` (no recommends), `firefox`, `x-www-browser` configured |
| **Dotfiles** | Installed from `https://lfendy-vim.github.io/init.sh` (skipped if already present) |

## Testing

Tests run inside a Podman/Docker container that mimics a fresh Ubuntu 26.04 server.

### Prerequisites

- [Podman](https://podman.io/) or [Docker](https://www.docker.com/) (auto-detected)

### Build & run tests

```bash
# Start or reuse a detached server container with the repo mounted
make server_local

# Run init.sh inside that container
make test_server

# Open an interactive shell in the server container (for debugging)
make bash_server

# Run init.sh in a disposable container (local mount)
make test_local

# Run init.sh in a disposable container (fetches from GitHub)
make test

# Open a disposable interactive shell
make bash

# Clean up containers and images
make clean
```

### Test images

| Image | Base | Contents |
|---|---|---|
| `llm-provision-test` | `ubuntu:26.04` | systemd, curl, sudo, dbus, `localuser` (passwordless sudo) |
| `llm-provision-test-cached` | `llm-provision-test` | Plus pre-cached `git`, `make`, `ansible` (via `install-deps.sh`) |

Set `LLM_PROVISION_TEST_CACHED=0` to use the uncached base image (tests are slower but closer to a truly fresh environment):

```bash
LLM_PROVISION_TEST_CACHED=0 make test_server
```

## Project structure

```
llm-provision/
├── Makefile                           # Top-level orchestration
├── init.sh                            # Entry point (deps → clone → ansible)
├── install-deps.sh                    # Shared dependency installer
├── ansible/
│   ├── Makefile                       # make bootstrap, make provision
│   ├── ansible.cfg                    # Default config
│   ├── inventory/local.ini            # local connection inventory
│   ├── playbooks/
│   │   ├── bootstrap.yml              # apt upgrade + devuser
│   │   └── provision.yml              # Full devuser provisioning
│   ├── tasks/
│   │   ├── bootstrap/
│   │   │   ├── apt_upgrade.yml
│   │   │   └── devuser.yml
│   │   └── provision/
│   │       ├── cli.yml                # CLI tools + oh-my-zsh
│   │       ├── podman.yml             # Podman + compose
│   │       ├── pi.dev.yml             # Node.js, pi agent, packages, models.json
│   │       ├── sshd.yml               # SSH server + authorized_keys
│   │       ├── gui.yml                # Xorg, openbox, firefox
│   │       └── dotfiles.yml           # Dotfiles from lfendy-vim.github.io
│   └── files/
│       ├── authorized_keys            # SSH public key for devuser
│       └── models.json                # pi agent provider/model config
└── test/
    ├── Dockerfile.llm-provision-test
    └── Dockerfile.llm-provision-test-cached
```
