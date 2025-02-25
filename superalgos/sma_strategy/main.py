import asyncio
import os
import logging

from superalgorithm.utils.config import config
from sma_sample_strategy import SMAStrategy
from superalgorithm.exchange import CCXTExchange
from superalgorithm.data.providers.ccxt import CCXTDataSource
from superalgorithm.exchange import PaperExchange
from superalgorithm.data.providers.csv import CSVDataSource
from superalgorithm.backtesting import session_stats, upload_backtest


logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("sample strategy")

symbol = config.get("symbol")


async def backtest_complete_handler(strategy: SMAStrategy):
    print(session_stats(strategy.exchange.position_manager.list_trades()))
    # requires superalgorithm API keys
    await upload_backtest()

async def main():


    logger.info(config["CSV_DATA_FOLDER"])
    mode = os.getenv("MODE", "live")
    
    if mode == "live":

        datasource = CCXTDataSource(symbol, "5m", exchange_id="binance")
        strategy = SMAStrategy(
            [datasource],
            CCXTExchange(exchange_id="binance", config={"apiKey": "", "secret": ""}),
        )

        await strategy.start()
        

    else:

        csv = CSVDataSource(symbol, "5m", csv_data_folder=config["CSV_DATA_FOLDER"])
        strategy = SMAStrategy([csv], PaperExchange())

        strategy.on("backtest_done", backtest_complete_handler)

        await strategy.start()


if __name__ == "__main__":

    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Shutting down...")
