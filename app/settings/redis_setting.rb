# encoding: UTF-8
class RedisSetting < Settingslogic
  source "#{Rails.root}/config/redis.yml"
  namespace Rails.env
end