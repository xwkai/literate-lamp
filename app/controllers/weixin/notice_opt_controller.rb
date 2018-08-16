class Weixin::NoticeOptController < Weixin::BaseController
  skip_before_action :verify_authenticity_token, :only => [:show,:save_info]
  def show
    # user = User.bunding_user(session[:openid])
    browser_type = request.env['HTTP_USER_AGENT'].downcase
    # unless user.blank?
    #   session_key = UserTerminalSession.get_session(user[:id],browser_type)
    #   redirect_to "http://srm.yolanda.hk/index?terminal_session_key="+session_key[:session_key]
    # else
      render "mobile/weixin/bind"
    # end
  end

  def save_info
    response_status = Hashie::Mash.new
    response_status.code = ResponseStatus::Code::ERROR

    if params[:order_number].present?
      order = Order.get_order_by_number(params[:order_number])
    end

    if order.present?
      access_token = Weixin.get_qy_access_token
      user_result = Weixin.get_qy_user(access_token,session[:openid])
      Rails.logger.info("#{__FILE__}:#{__LINE__} weixin gzh_user_info #{user_result}")

      unless user_result["openid"].present?
        response_status.msg = '服务出错'
        render json:response_status
        return
      end

      return_info = ReturnInfo.get_info_by_order(order.id,user_result["openid"])

      if return_info.present?
        response_status.msg = '该订单号已经提交，请勿重复提交订单'
        render json:response_status
        return
      end

      params[:order_id] = order.id
      params[:wx_id] = user_result["nickname"]
      params[:openid] = session[:openid]
      @user_info = user_result["headimgurl"]
      upload_flag, url = Common.upload_to_qiniu(params[:praise_img],'yolanda')
      params[:praise_img] = url
      response_status = ReturnInfo.save_info(params)
    else
      response_status.msg = '查无该订单号，请核实后重新填写。'
    end

    render json:response_status
  end

  def reward
    data = []
    query = ReturnInfo.select("order_number,platform,back_status,return_infos.created_at")
    query = query.joins("left join orders o on o.id = return_infos.order_id")
    query = query.where("openid = ?","oTqlZ0b2_3ETcHHGgT050SczP8H8")
    if query.present?
      query.each do |item|
        data << {
            order_number:item.try(:order_number),
            platform:item.try(:platform),
            back_status:item.try(:back_status),
            created_at:Time.at(item.try(:created_at)).strftime("%Y%m%d"),
        }
      end
    end
render json: {data:data}
    # render "mobile/weixin/reward"
    # redirect_to :action => 'mobile/weixin/reward', id: @return_info
  end


end