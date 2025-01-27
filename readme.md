# Superalgorithm CLI

A command-line tool for managing algorithmic trading strategies.

## Installation

```bash
curl -o- https://raw.githubusercontent.com/superalgorithm/superalgorithm-cli/main/install.sh | bash
```

Dependencies (installed automatically):

- fswatch: For file watching
- yq: For YAML processing

Requires docker to be installed on your local and remote system.

## Quick Start

```bash
cd your-project-folder
superalgorithm
```

## Features

### 1. Test Strategies Locally

Run strategies in backtest or live mode using the MODE environment variable:

```python
# main.py
mode = os.getenv("MODE", "live")
if mode == "live":
    # Live trading logic
else:
    # Backtest logic
```

Any file changes will automatically trigger a re-build of the docker container.

### 2. Deploy to Remote Server

Deploy strategies to a remote server. Configure `.env` using:

- REMOTE_SERVER: Your server address
- REMOTE_USER: SSH username

Ensure you have SSH access to your remote server. Check [this guide](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/) or consult with your hosting provider.

Ensure Docker is installed on your remote host. For example, you can use a [Digital Ocean One-Click Docker Droplet](https://marketplace.digitalocean.com/apps/docker).

### 3. Manage Running Strategies

Control your strategies with simple commands:

- start
- stop
- restart
- logs
- status

### 4. Initialize New Project

Use this option to initialize a new project with:

- base_images/: Base Docker images and global configs
- common/: Shared code across strategies
- superalgos/: Individual trading strategies
  - Each strategy has its own Dockerfile and configs
  - Configs are merged automatically:

```yaml
# Global config (base_images/default/config.yaml)
api_key: YOUR_API_KEY
global_config:
  exchange: binance

# Strategy config (superalgos/<strategy>/configs/config.yaml)
symbol: BTC/USDT
global_config:
  exchange: kraken

# Result: Merged automatically and uploaded as config.yaml
api_key: YOUR_API_KEY
symbol: BTC/USDT
global_config:
  exchange: kraken
```

### 5. Update & Uninstall

- Update: Get the latest CLI version
- Uninstall: Remove CLI from your systems

# Docker setup

You can change this to your liking but the default setup is using a docker-compose file and creates all strategies from the base_images/default folder. You can then configure each strategy container using the Dockerfile, requirements.txt and config.yaml files.

Common code will be deployed to all strategies.
