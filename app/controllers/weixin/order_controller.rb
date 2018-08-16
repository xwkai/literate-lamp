class Weixin::OrderController < ApplicationController

  #订单查询
  def list
    @response_status = Order.select_order(params)
    render json: @response_status
  end

  #好评返现信息
  def back_list
    @response_status = ReturnInfo.get_all(params)
    render json: @response_status
  end

  #返现订单
  def cashback

  end

  #资金流水
  def capital_flow
    @response_status = Capital.get_all_capital(params)
    render json: @response_status
  end

  #充值
  def recharge

  end

end