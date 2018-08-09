class Weixin::VerifyController < Weixin::BaseController
  require 'rexml/document'

  def create
    #签名
    if not Weixin.valid_msg_signature(params)
      Rails.logger.debug("#{__FILE__}:#{__LINE__} Failure because signature is invalid")
      render plain: "", status: 401
      return
    end
    param_xml = request.body.read
    Rails.logger.debug("____________#{param_xml}_____________")

    param_xml = REXML::Document.new(param_xml)


    to_user  = param_xml.root.elements['FromUserName'].text
    from_user  = param_xml.root.elements['ToUserName'].text
    msg_type  = param_xml.root.elements['MsgType'].text

    description = "您好，欢迎关注伊欧乐供应商管理平台！[微笑]"
    content = Weixin.response_msg_xml(to_user,from_user, description)

    render plain: content
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
  def create_menu
    #通过code获取access_token
    access_token = Weixin.get_qy_access_token
    post_url = "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{access_token}"
    origin_path = "http%3a%2f%2fxwk.ddns.yolanda.hk%2fweixin%2fnotice_opt%2fshow" # 使用urlEncode对链接进行处理
    post_hash = {:button => [
                                {
                                    :type => "view",
                                    :name => "SRM管理系统",
                                    :url => "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{WeixinSetting.corpId}&redirect_uri=#{origin_path}&response_type=code&scope=snsapi_base#wechat_redirect"
                                }
                            ]
                }
    # 转json格式后含不合法的请求字符，不能包含\uxxxx格式的字符以&替换
    post_hash = post_hash.to_json
    post_hash["\\u0026"] = "&"
    post_hash["\\u0026"] = "&"
    post_hash["\\u0026"] = "&"
    Base.http_request(post_url,'Post',post_hash)
  end

end