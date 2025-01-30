import asyncio
import os
import logging
from superalgorithm.utils.config import config
from common.utils import common_hello

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("sample strategy")


async def main():

    mode = os.getenv("MODE", "live")

    # verify we can load modules from common
    common_hello()

    
    if mode == "live":
        # place your live strategy code here
        logger.info("Running in live mode.")

        while True:
            logger.info(config["exchange"])
            logger.info(config["budget"])
            logger.info(config["api_key"])
            logger.info(["change this line to make watchdog restart during live mode."])
            await asyncio.sleep(2)
    else:
        # place your backtest code here
        logger.info("Running in backtest mode.")
        logger.info("Backtest completed.")

if __name__ == "__main__":

    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Shutting down...")
