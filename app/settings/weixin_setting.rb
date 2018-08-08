# encoding: UTF-8
class WeixinSetting < Settingslogic
  source "#{Rails.root}/config/weixin.yml"
  namespace Rails.env
end