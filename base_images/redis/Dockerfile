FROM redis:7.2-alpine

# Copy custom redis configuration if needed
# COPY redis.conf /usr/local/etc/redis/redis.conf

EXPOSE 6379

# Run Redis with protected mode disabled for development
CMD ["redis-server", "--protected-mode", "no"]