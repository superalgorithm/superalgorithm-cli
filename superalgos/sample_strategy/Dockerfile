FROM trading-base:latest

WORKDIR /app

COPY superalgos/market_making_strategy /app/

RUN pip install --no-cache-dir -r requirements.txt

# ENV PYTHONPATH=/app
# ENV SUPER_STRATEGY_ID=sol_mean_reversion
# CMD ["python", "-u", "./main.py"]
