from superalgorithm.strategy.base_strategy import BaseStrategy
from superalgorithm.types import (
    Bar,
    OrderType,
    PositionType,
    ChartSchema,
    ChartPointDataType,
)
from superalgorithm.utils.logging import set_chart_schema, chart, monitor
from talipp.indicators import SMA

class SMAStrategy(BaseStrategy):

    def init(self):
        self.state = "IDLE"
        self.on("5m", self.on_5)
        self.sma = SMA(14)
        self.sma_slow = SMA(200)

        set_chart_schema(
            [
                ChartSchema(
                    "BTC/USDT", ChartPointDataType.OHLCV, "candlestick", "orange"
                ),
                ChartSchema("sma", ChartPointDataType.FLOAT, "line", "red"),
                ChartSchema("sma_slow", ChartPointDataType.FLOAT, "line", "blue"),
                ChartSchema(
                    "long", ChartPointDataType.FLOAT, "scatter", chart_color="green"
                ),
                ChartSchema(
                    "short", ChartPointDataType.FLOAT, "scatter", chart_color="red"
                ),
            ]
        )

    async def on_5(self, bar: Bar):

        self.sma.add(bar.close)
        self.sma_slow.add(bar.close)

        chart("BTC/USDT", bar.ohlcv)
        chart("sma", self.sma[-1])
        chart("sma_slow", self.sma_slow[-1])

        await self.trade_logic()

    async def on_tick(self, bar: Bar):
        pass

    async def trade_logic(self):

        if len(self.sma_slow) < 2 or self.sma_slow[-2] is None:
            return

        close = self.get("BTC/USDT", "5m").close

        buy = self.sma[-2] < self.sma_slow[-2] and self.sma[-1] > self.sma_slow[-1]
        sell = self.sma[-2] > self.sma_slow[-2] and self.sma[-1] < self.sma_slow[-1]

        if buy:
            await self.open("BTC/USDT", PositionType.LONG, 0.1, OrderType.LIMIT, close)
            chart("long", close)
            self.state = "OPEN"

        if sell:
            await self.close("BTC/USDT", PositionType.LONG, 0.1, OrderType.LIMIT, close)
            chart("short", close)
            self.state = "IDLE"

        monitor("state", self.state)
