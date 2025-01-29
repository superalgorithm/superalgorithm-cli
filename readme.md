# Superalgorithm CLI

A command-line tool for managing algorithmic trading strategies built with [superalgorithm](https://github.com/superalgorithm).

## Installation

```bash
curl -o- https://raw.githubusercontent.com/superalgorithm/superalgorithm-cli/main/install.sh | bash
```

Dependencies (installed automatically):

- yq: For YAML processing

Requires docker to be installed on your local and remote system.

## Quick Start

```bash
cd your-project-folder
superalgorithm
```

## Project structure

### base_images

Contains Docker configurations for your trading strategies. Each base image can have:

- A custom Dockerfile for specific dependencies
- A `config.yaml` for shared configuration
- A `requirements.txt` for Python packages

The default image can be overridden in your `superalgos/<strategy>/configs` file:

```yaml
docker_image: custom_docker_setup
```

### common

The code in this folder will be deployed and shared with all strategies.

### superalgos

Contains the individual strategies. By default each strategy requires a `main.py` file as entry point.

Each strategy is run using `yaml` configurations files in `superalgos/<strategy>/configs`, enabling you to run the strategy with different configurations (trading pair, budget, etc.)

Example:

```yaml
exchange: binance
pair: btc/usdt
budget: 50000
decay: 0.9999
```

Use `from superalgorithm.utils.config import config` to read the configuration data:

```python
from superalgorithm.utils.config import config
print(config.get("exchange"))
```

### tests

Python tests for your common code.

## Features

### 1. Test strategies locally

The `MODE` environment variable is set to "live" or "backtest" based on your selection, which you can check in `main.py` to run the appropriate strategy code.

```python
# main.py
from superalgorithm.utils.config import config

mode = config.get("MODE")
if mode == "live":
    # Live trading logic
else:
    # Backtest logic
```

**HOT RELOAD**

File changes to .py files automatically restart your strategy without rebuilding the container, enabling rapid development and testing.

Check the `sma_strategy` folder for an example.

### 2. Deploy to a remote server

You can deploy your strategies to a remote server by creating an `.env` file in the project root with the following variables:

- REMOTE_SERVER: Your server address
- REMOTE_USER: SSH username

Ensure you have SSH access configured to access your remote server. Check [this guide](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/) or consult with your hosting provider.

Ensure Docker is installed on your remote host. For example, you can use a [Digital Ocean One-Click Docker Droplet](https://marketplace.digitalocean.com/apps/docker).

When deploying to the remote server the cli will upload the following files:

- base_images/\<default>/\*
- common/\*\*
- superalgos/\<selected strategy>\/\*\* (excluding the configs folder)

**Config Merging Logic:**

During the build process the selected config from the `superalgos/<strategy>/configs` folder will be merged with the default config from `base_images/<default>/config.yaml` and uploaded as the final `config.yaml` in the container root.

This enables you to place common configuration information in `base_images/<default>/config.yaml` and read or override these for each individual strategy you are running.

You can read the configuration data using `from superalgorithm.utils.config import config` as explained above.

Check the `sample_strategy` for a demo on how it reads default and overwrites data. To make this work rename the demo config.yaml.template to config.yaml.

### 3. Manage running strategies

Control your strategies with simple commands on both your local and remote machines:

- start
- stop
- restart
- logs
- status

### 4. Initialize a new project

Use this option to initialize a new project from the starter template and create the default folders, files, and sample configurations.

### 5. Update & uninstall

- Update: Get the latest CLI version
- Uninstall: Remove CLI from your systems
