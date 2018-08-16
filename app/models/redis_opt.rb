#encoding: utf-8

class RedisOpt

  @redis  = $redis

  ####hash类##################缓存写入，如用户基本资料，session
  def self.redis_hash_write(key, hash)

    @redis.hmset(key, *hash.map{|k, v| [k,v]})
  end

  #更新hash某个值
  def self.redis_hash_write_k(key, k, v)
    @redis.hset(key, k, v)
  end

  #用户session
  def self.redis_hash_write_session(key, session_key)
    updated_at = Time.new.gmtime.strftime('%Y-%m-%d %H:%M:%S')
    session_hash = {key:session_key, updated_at:updated_at}
    self.redis_hash_write(key, session_hash)
  end

  # hash field自增
  def self.redis_hash_incr(key, field, integer)
    @redis.hincrby(key, field, integer)
  end

  def self.redis_hash_del(key)
    @redis.del(key)
  end

  #读取
  def self.redis_hash_read(key)
    @redis.hgetall(key)
  end

  def self.redis_hash_read_k(key, k)
    @redis.hget(key, k)
  end

  # HEXISTS key field
  def self.redis_hexists(key, field)
    @redis.hexists(key, field)
  end

  # HSETNX key field value
  def self.redis_hsetnx(key, k, v)
    @redis.hsetnx(key, k, v)
  end

  #获得哈希表中key对应的所有field
  def self.redis_hkeys(key)
    @redis.hkeys(key)
  end

  ############zet类#############################
  def self.redis_zset_write(key, score, value)
    @redis.zadd(key, score, value)
  end

  def self.redis_zset_read(key, value)
    @redis.zscore(key, value)
  end

  #删除某个KEY中的一个元素
  def self.redis_zset_del(key, value)
    @redis.zrem(key, value)
  end

  #移除score值介于min和max之间（等于）的成员
  def self.redis_zremrangebyscore(key, min, max)
    @redis.zremrangebyscore(key, min, max)
  end

  #自增，用于点赞，查看次数的保存
  def self.redis_zincrby(key, value, field)
    @redis.zincrby(key, value, field)
  end

  # zet数量
  def self.redis_zcard(key)
    @redis.zcard(key)
  end

  # 成员的位置按 score 值递增(从小到大)来排列
  def self.redis_zrange(key, min, max)
    @redis.zrange(key, min, max, :with_scores => true)
  end

  # 递减
  def self.redis_zrevrange(key, min, max)
    @redis.zrevrange(key, min, max, :with_scores => true)
  end

  #返回有续集key中score<=max并且score>=min 的元素，返回结果根据score从大到小顺序排列。
  # 可选参数withscores决定结果集中是否包含score，可选参数limit 指定返回结果集范围。
  def self.redis_zrevrangebyscore(key,  max, min)
    @redis.zrevrangebyscore(key, max, min, :with_scores => true)
  end

  ##########对Set操作的命令###################
  def self.redis_set_write(key, value)
    @redis.sadd(key, value)
  end

  #返回所有元素
  def self.redis_set_read(key)
    @redis.smembers(key)
  end

  def self.redis_set_del(key, value)
    @redis.srem(key, value)
  end

  #查找是否存在
  def self.redis_set_sismember(key, field)
    @redis.sismember(key, field)
  end

  ##########对String操作的命令##############
  # SETEX key seconds value
  def self.redis_setex(key, sec, value)
    @redis.setex(key, sec, value)
  end

  # SET key
  def self.redis_set(key, value)
    @redis.set(key, value)
  end

  # GET key
  def self.redis_get(key)
    @redis.get(key)
  end

  def self.redis_inc(key)
    @redis.incr(key)
  end

  ##########对Key操作的命令##############
  # EXPIRE key seconds
  def self.redis_expire(key, sec)
    @redis.expire(key, sec)
  end

  # EXISTS key
  def self.redis_exists(key)
    @redis.exists(key)
  end

  def self.redis_del(key)
    @redis.del(key)
  end

  def self.redis_keys(key)
    @redis.keys(key)
  end

  def self.current_redis
    @redis  = Redis.current
  end

  ##批量删除key###
  # Public::Redis.bat_del_keys('keys:*')
  def self.bat_del_keys(key)
    keys = @redis.keys(key)

    keys.collect { |item| redis_del(item)} if keys.present?

  end

end