import asyncio
import os
import logging
from superalgorithm.utils.config import config

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("market_maker")


async def main():
    config_path = "config.yaml"
    logger.error(os.listdir("/"))
    if not os.path.exists(config_path):
        logger.error(f"Config file not found at {config_path}")
        logger.error("Current directory contents:")
        logger.error(os.listdir("/"))
        raise FileNotFoundError(f"Config file not found at {config_path}")
    else:
        logger.info(f"Config file found at {config_path}")

    environment = os.getenv("MODE", "live")

    while True:
        logger.info(f"Running in {environment} mode.")
        logger.info(config["default_config"])
        await asyncio.sleep(2)


if __name__ == "__main__":

    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Shutting down...")
