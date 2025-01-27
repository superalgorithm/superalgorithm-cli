import asyncio
import os
import logging
from superalgorithm.utils.config import config

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("sample strategy")


async def main():

    mode = os.getenv("MODE", "live")

    if mode == "live":
        # place your live strategy code here
        logger.info("Running in live mode.")
    else:
        # place your backtest code here
        logger.info("Running in backtest mode.")

    while True:
        logger.info(config["exchange"])
        logger.info(config["budget"])
        logger.info(config["api_key"])
        await asyncio.sleep(2)


if __name__ == "__main__":

    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Shutting down...")
