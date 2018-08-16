# encoding: UTF-8

redis_url = "redis://#{RedisSetting.username}:#{RedisSetting.password}@#{RedisSetting.host}:#{RedisSetting.port}"

$redis = Redis::Namespace.new(RedisSetting.namespace, redis: Redis.new(url: "#{redis_url}/#{RedisSetting.db}"))
