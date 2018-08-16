class Order < ApplicationRecord

  def self.get_order_by_id(id)
    self.where("id = ? ",id).first
  end

  def self.get_order_by_number(order_number)
    self.select("id").where("order_number = ?",order_number).first
  end

  def self.select_order(params)
    response_status = Hashie::Mash.new
    pageNum = params[:pageNum] ? params[:pageNum].to_i : 1
    pageSize = params[:pageSize] ? params[:pageSize].to_i : 20
    wx_id = params[:wx_id]
    order_number = params[:order_number]
    back_status = params[:back_status]
    data = []

    query = self.select("order_number,platform,status,created_at")

    if wx_id.present?
      query = query.where("wx_id = ?",wx_id)
    end

    if order_number.present?
      query = query.where("order_number = ?",order_number)
    end

    if back_status.present?
      query = query.where("back_status = ?",back_status)
    end
    recordsTotal = query.length
    query = query.order("created_at desc").page(pageNum).per(pageSize)
    if query.present?

      query.each do |item|
        data << {
            created_at: Time.at(item.try(:created_at)).strftime("%Y%m%d"),
            platform: item.try(:platform),
            order_number: item.try(:order_number),
            status: item.try(:status)
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
