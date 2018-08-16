class Weixin


  #获取access_token
  def self.get_qy_access_token

    #从缓存中获取
    access_token = RedisOpt.redis_get("qy_access_token")

    if access_token.blank?
      #通过code获取access_token
      url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{WeixinSetting.corpId}&secret=#{WeixinSetting.secret}"

      result = Base.http_request(url,'Get',nil)

      Rails.logger.info("Weixin get token response: #{result}")

      access_token = result['access_token']

      RedisOpt.redis_set("qy_access_token", access_token)
      RedisOpt.redis_expire("qy_access_token", 7200)
    end
    return access_token
  end

  #通过access_token和openid获取用户基本信息
  def self.get_qy_user(access_token, openid)

    url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{access_token}&openid=#{openid}&lang=zh_CN"
    user_result = Base.http_request(url,'Get',nil)

    Rails.logger.info("Weixin oauth2 user info response: #{user_result}")

    return user_result
  end

  #验证签名
  def self.valid_msg_signature(params)
    qy_token = WeixinSetting.token
    timestamp         = params[:timestamp]
    nonce             = params[:nonce]
    msg_signature     = params[:signature]
    sort_params       = [qy_token, timestamp, nonce].sort.join
    current_signature = Digest::SHA1.hexdigest(sort_params)
    Rails.logger.info("params:#{params}, current_signature: #{current_signature}")
    current_signature == msg_signature
  end

  #文本消息
  def self.msg_text_format(touser,fromuser, content)
    "<xml>
      <ToUserName><![CDATA[#{touser}]]></ToUserName>
      <FromUserName><![CDATA[#{fromuser}]]></FromUserName>
      <CreateTime>#{Time.now.to_i.to_s}</CreateTime>
      <MsgType><![CDATA[text]]></MsgType>
      <Content><![CDATA[#{content}]]></Content>
    </xml>"
  end

  #扫描事件响应消息xml
  def self.response_msg_xml(touser,fromuser,description)
    self.msg_text_format(touser,fromuser, description)
  end

end