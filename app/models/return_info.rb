class ReturnInfo < ApplicationRecord

  # 返现状态 1审核中 2已返现 3审核失败，请联系客服
  module SOURCE_CATEGORY
    AUDIT = 1
    REAPPEARANCE = 2
    AUDIT_FAIL = 3
  end

  def self.get_infos_by_openid(openid)
    self.where("openid = ?",openid)
  end

  def self.get_info_by_order(order_id,openid)
    self.select("id").where("order_id = ? and openid = ?",order_id,openid).first
  end

  def self.save_info(params)
    response_status = Hashie::Mash.new
    order = Order.get_order_by_number(params[:order_number])
    response_status.code = ResponseStatus::Code::ERROR
    if order.present?
      params[:back_status] = ReturnInfo::SOURCE_CATEGORY::AUDIT
      return_info = self.get_info_by_order(params[:order_id],params[:openid])
      if return_info.present?
        response_status.msg = "该订单号已经提交，请勿重复提交订单"
        return response_status
      end
      result = Base.save_model_attributes(self, '返现信息', params)

      unless result[:status]
        response_status.msg = "上传数据出错"
        return response_status
      end
      response_status.code = ResponseStatus::Code::SUCCESS

    else
      response_status.msg = "查无该订单号，请核实后重新填写。"
    end

    return response_status
  end

  def self.update_info(params)
    response_status = Hashie::Mash.new
    return_info = self.where("id = ?",params[:id]).first
    if return_info.present?
      update_params = Base.get_accessible_attributes(self,params)
      return_info.update_attributes(update_params)
    end

    response_status.code = ResponseStatus::Code::SUCCESS

    return response_status
  end

  def self.get_return_info(params)
    response_status = Hashie::Mash.new
    data = []
    query = self.get_infos_by_openid(params[:openid])
    if query.present?
      query.each do |item|
        order = Order.get_order_by_id(item.try(:order_id))
        praise_img_ary = item.try(:praise_img).split(',')
        if item.try(:finished_at).present?
          finished_at = item.try(:finished_at).strftime('%Y%m%d %H:%M')
        else
          finished_at = ''
        end
        return_info = {
            wx_id: item.try(:wx_id).to_s,
            openid: item.try(:openid).to_s,
            platform: item.try(:platform).to_i,
            order_number: order.order_number,
            praise_img_ary: praise_img_ary,
            back_status: item.try(:back_status).to_i,
            finished_at: finished_at,
            created_at: (item.try(:created_at).to_i+8*3600).strftime('%Y%m%d %H:%M')
        }

        data << return_info
      end
    end
    response_status.code = ResponseStatus::Code::SUCCESS
    response_status.data = data

    return response_status

  end

  def self.get_all(params)
    response_status = Hashie::Mash.new
    pageNum = params[:pageNum] ? params[:pageNum].to_i : 1
    pageSize = params[:pageSize] ? params[:pageSize].to_i : 20
    order_number = params[:order_number]
    wx_id = params[:wx_id]
    back_status = params[:back_status]
    finished_at = params[:finished_at]
    data = []

    query = self.select("order_number,o.platform,o.wx_id,back_status,o.tb_id,o.purchase_time,o.purchase_amount,praise_img,finished_at,o.return_amount,return_infos.created_at")
    query = query.joins("left join orders o on o.id=return_infos.order_id")

    if wx_id.present?
      query = query.where("o.wx_id = ?",wx_id)
    end

    if order_number.present?
      query = query.where("order_number = ?",order_number)
    end

    if back_status.present?
      query = query.where("back_status = ?",back_status)
    end

    if finished_at.present?
      start_time = Time.parse(finished_at).strftime("%Y-%m-%d")+' 00:00:00'
      end_time = Time.parse(finished_at).strftime("%Y-%m-%d") + ' 23:59:59'
      query = query.where("finished_at >= ? and finished_at <= ?",start_time,end_time)
    end

    recordsTotal = query.length
    query = query.order("created_at desc").page(pageNum).per(pageSize)
    if query.present?

      query.each do |item|
        praise_img = Common.get_url_from_qiniu('yolanda',item.try(:praise_img))
        data << {
            created_at: Time.at(item.try(:created_at)).strftime("%Y%m%d %H:%M"),
            platform: item.try(:platform),
            order_number: item.try(:order_number),
            wx_id: item.try(:wx_id),
            tb_id: item.try(:tb_id),
            purchase_time: item.try(:purchase_time).strftime("%Y%m%d"),
            purchase_amount: item.try(:purchase_amount),
            praise_img: praise_img,
            finished_at: item.try(:finished_at).present? ? item.try(:finished_at).strftime("%Y%m%d %H:%M")  : '',
            return_amount: item.try(:return_amount),
            back_status: item.try(:back_status)
        }
      end
    end

    response_status.code = ResponseStatus::Code::SUCCESS
    response_status.data = data
    response_status.recordsTotal = recordsTotal
    response_status.pageNum = pageNum

    return response_status
  end

end
