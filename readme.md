# Superalgorithm CLI

A command-line tool for managing algorithmic trading strategies built with [superalgorithm](https://github.com/superalgorithm).

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

Test strategies in backtest or live mode on your local machine.

When selecting "live", the MODE environment variable is set to "live" and the `main.py` file will run in live mode on the development machine. If you select "backtest", the MODE environment variable is set to "backtest" and the `main.py` file will run in backtest mode. Below is a sample switch you can use to run the respective code:

```python
# main.py
mode = os.getenv("MODE", "live")
if mode == "live":
    # Live trading logic
else:
    # Backtest logic
```

Any file changes will automatically trigger a re-build of the docker container. This enables you to make changes and test your strategies without continously running docker commands. To stop automative re-builds simply exit the command with `ctrl + c`.

Check the `sma_strategy` folder for an example setup.

### 2. Deploy to Remote Server

To deploy strategies to a remote server create an `.env` with the following variables:

- REMOTE_SERVER: Your server address
- REMOTE_USER: SSH username

Ensure you have SSH access to your remote server. Check [this guide](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/) or consult with your hosting provider.

Ensure Docker is installed on your remote host. For example, you can use a [Digital Ocean One-Click Docker Droplet](https://marketplace.digitalocean.com/apps/docker).

When deploying to the remote the cli will upload the following files:

- base_images/default/\*
- common/\*
- superalgos/<selected strategy>\* (excluding configs folder)

**Config Merging Logic:**

During the build process the selected config from the `superalgos/<strategy>/configs` folder will be merged with the default config from `base_images/default/config.yaml` and uploaded as the final `config.yaml` in the container root.

This enables you to place common configuration information in `base_images/default/config.yaml` and read or override these for each individual strategy you are running.

You can read the configuration data using `from superalgorithm.utils.config import config`.

Check the sample_strategy for a demo on how it reads default and overwrites data. To make this work rename the demo config.yaml.template to config.yaml.

### 3. Manage Running Strategies

Control your strategies with simple commands on both your local and remote machines:

- start
- stop
- restart
- logs
- status

### 4. Initialize New Project

Use this option to initialize a new project from the starter template:

- base_images/: Base Docker images and global configs are stored here. Create a config.yaml file inside base_images/default and store your global configs here (API keys etc. you want to use across your different strategies).
- common/: Shared code and files used across strategies
- superalgos/: Individual trading strategies
  - Each strategy has its own Dockerfile and requirements.txt for granular control
  - main.py is the entry point for your strategy
  - superalgos/configs: create one or more yaml files configuring your strategy. These configs are extending base_images/default/config.yaml:

```yaml
# Global config (base_images/default/config.yaml)
api_key: YOUR_API_KEY
global_config:
  exchange: binance

# Strategy config (superalgos/<strategy>/configs/btc_usdt.yaml)
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

# Docker setup details

The default setup is using a docker-compose file using base_images/default as base image. You can then configure each strategy container further using their respective Dockerfile, requirements.txt and config.yaml files.

Examples:

- superalgos/<strategy>/configs/btc_usdt.yaml
- superalgos/<strategy>/configs/doge_usdt.yaml
- superalgos/<strategy>/configs/doge_binance_usdt.yaml
- superalgos/<strategy>/configs/doge_kraken_usdt.yaml
- superalgos/<strategy>/Dockerfile
- superalgos/<strategy>/requirements.txt

All files and code in `common` will be deployed to all strategies.
