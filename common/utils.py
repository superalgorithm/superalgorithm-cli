import logging
from typing import Any, Dict
import time


def setup_logging(config: Dict[str, Any]) -> logging.Logger:
    """Setup logging configuration based on config settings."""
    log_level = config.get("logs", {}).get("level", "INFO")
    logger = logging.getLogger("trading_strategy")
    logger.setLevel(log_level)

    handler = logging.StreamHandler()
    formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    return logger


def retry_with_backoff(max_retries: int = 3, backoff_factor: float = 1.5):
    """Decorator for retrying functions with exponential backoff."""

    def decorator(func):
        def wrapper(*args, **kwargs):
            retries = 0
            while retries < max_retries:
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    retries += 1
                    if retries == max_retries:
                        raise e
                    wait_time = backoff_factor**retries
                    time.sleep(wait_time)
            return None

        return wrapper

    return decorator
