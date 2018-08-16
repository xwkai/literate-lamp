class Weixin::VerifyController < Weixin::BaseController
  require 'rexml/document'
  skip_before_action :verify_authenticity_token, :only => [:create]
  def create
    pp '================create==============='
    render "mobile/weixin/bind"
  end


  #验证url
  #返回
  # Parameters {"msg_signature"=>"8c78dcafc913b1", "timestamp"=>"1476424643", "nonce"=>"807676103", "echostr"=>"5Mu711bsklc3g==", "controller"=>"weixin/verify", "action"=>"index"}
  def index
    if not Weixin.valid_msg_signature(params)
      Rails.logger.debug("#{__FILE__}:#{__LINE__} Failure because signature is invalid")
      render plain: "", status: 401
      return
    end

    render plain: params[:echostr]
  end

  # 自定义菜单
  # def create_menu
  #   #通过code获取access_token
  #   access_token = Weixin.get_qy_access_token
  #   post_url = "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{access_token}"
  #   origin_path = "http%3a%2f%2fxwk.ddns.yolanda.hk%2fweixin%2fnotice_opt%2fshow" # 使用urlEncode对链接进行处理
  #   post_hash = {:button => [
  #                               {
  #                                   :type => "view",
  #                                   :name => "SRM管理系统",
  #                                   :url => "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{WeixinSetting.corpId}&redirect_uri=#{origin_path}&response_type=code&scope=snsapi_base#wechat_redirect"
  #                               }
  #                           ]
  #               }
  #   # 转json格式后含不合法的请求字符，不能包含\uxxxx格式的字符以&替换
  #   post_hash = post_hash.to_json
  #   post_hash["\\u0026"] = "&"
  #   post_hash["\\u0026"] = "&"
  #   post_hash["\\u0026"] = "&"
  #   Base.http_request(post_url,'Post',post_hash)
  # end

end