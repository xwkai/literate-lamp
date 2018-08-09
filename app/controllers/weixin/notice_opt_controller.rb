class Weixin::NoticeOptController < Weixin::BaseController

  def show
    user = User.bunding_user(session[:openid])
    browser_type = request.env['HTTP_USER_AGENT'].downcase
    unless user.blank?
      session_key = UserTerminalSession.get_session(user[:id],browser_type)
      redirect_to "http://srm.yolanda.hk/index?terminal_session_key="+session_key[:session_key]
    else
      render "/weixin/notice_opt/bind"
    end
  end

  def save_bind
    params[:ip] = request.remote_ip
    params[:browser_type] = request.env['HTTP_USER_AGENT'].downcase
    backup_hash = User.sign_in(params)
    user = backup_hash[:user]
    if backup_hash[:status_code] == ResponseStatus::Code::SUCCESS
      params[:weixin] = session[:openid]
      params[:id] = user[:user_id]
      User.update_user(params)
      redirect_to "http://srm.yolanda.hk/index?terminal_session_key="+backup_hash[:terminal_session_key]
    else
      data = { msg:false }
      render json: data
    end
  end

  # PMS 发送请求到SRM 推送消息到微信公众号用户
  # step 所处步骤，supplier_id供应商id,  msg 消息内容
  def wx_notice
    openids = User.get_openids_for_supplier(params[:supplier_id])
    content = params[:msg]
    access_token = Weixin.get_qy_access_token
    i = 0
    while i < openids.length  do
      post_url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}"
      post_hash = {
          :touser => openids[i],
          :msgtype => "text",
          :text => { content: content}
      }
      result = Base.http_request(post_url,'Post',post_hash)
      i +=1
    end
    return result  # {"errcode"=>0, "errmsg"=>"ok"}
  end

end