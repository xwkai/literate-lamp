class Capital < ApplicationRecord

  def self.get_all_capital(params)
    response_status = Hashie::Mash.new
    pageNum = params[:pageNum] ? params[:pageNum].to_i : 1
    pageSize = params[:pageSize] ? params[:pageSize].to_i : 20
    back_status = params[:back_status]
    time = params[:time]
    data = []

    query = self.select("o.order_number,flow_number,time,platform,return_amount").joins("left join orders o on o.id=capitals.order_id")
    # query = self
    if back_status.present?
      query = query.where("back_status = ?",back_status.to_i)
    end

    if time.present?
      start_time = Time.parse(time).strftime("%Y-%m-%d")+' 00:00:00'
      end_time = Time.parse(time).strftime("%Y-%m-%d") + ' 23:59:59'
      query = query.where("time >= ? and time <= ?",start_time,end_time)
    end
    recordsTotal = query.length
    query = query.order("time desc").page(pageNum).per(pageSize)
    if query.present?

      query.each do |item|
        data << {
            flow_number: item.try(:flow_number),
            time: item.try(:time).strftime("%Y%m%d"),
            platform: item.try(:platform),
            order_number: item.try(:order_number),
            return_amount: item.try(:return_amount)
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
