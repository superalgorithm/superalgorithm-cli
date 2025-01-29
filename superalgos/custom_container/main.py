import asyncio
import os
import logging
from superalgorithm.utils.config import config
from common.utils import common_hello

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("custom_docker_setup")

async def main():
    mode = os.getenv("MODE", "live")

    logger.info("This container should use the 'custom_docker_setup'.")
    logger.info("If not it will throw an error.")

    if logger.info(config["using_custom_docker_base"]) == False:
        raise Exception("using_custom_docker_base not found")

    if mode == "live":
        # place your live strategy code here
        logger.info("Running in live mode!")

        while True:
            logger.info("buying more coins")
            await asyncio.sleep(20)
    else:
        # place your backtest code here
        logger.info("Running in backtest mode.")
        logger.info("Backtest completed.")

if __name__ == "__main__":

    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Shutting down...")
