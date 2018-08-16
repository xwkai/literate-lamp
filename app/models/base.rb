# encoding: UTF-8
class Base

  # 请求类型
  module Request_Type
    GET = 'Get'
    POST = 'Post'
  end

  def self.save_model_attributes(obj, name, params)
    result = {}
    result[:status] = true

    return result if params.blank?

    update_params = {}
    update_id = params[:id].to_i
    attributes_ary = obj.attribute_names

    params.each do |key, value|
      if attributes_ary.include?(key.to_s)
        value = value.to_json if value.is_a?(Hash)
        if update_id.present? && update_id > 0  # 存在id，即编辑状态下
          update_params[key.to_sym] = value unless value.blank? # 字段值为空，则不需要加入到修改中去
        else  # 新增情况下，需要保存的字段
          update_params[key.to_sym] = value
        end
      end
    end
    unless params[:password].blank?
      update_params.reverse_merge!({password:params[:password]})
    end
    begin
      obj.transaction do
        if update_id.present? && update_id > 0
          update_data = obj.find_by_id(update_id)
          update_data.update_attributes!(update_params)
        else
          update_data = obj.create!(update_params)
        end

        result[:data] = update_data
      end

    rescue => e
      Rails.logger.error("Save #{name} params data fail.  #{e}")
      result[:msg] = "保存 #{name} 数据出错"
      result[:status] = false
    end

    return result
  end

  #获取类对象可更新的字段参数
  def self.get_accessible_attributes(obj, params)
    update_params = {}

    return update_params if params.blank?

    update_params = {}
    attributes_ary = obj.attribute_names

    params.each do |key, value|
      if attributes_ary.include?(key.to_s)
        value = value.to_json if value.is_a?(Hash)
        # 新增情况下，需要保存的字段
        update_params[key.to_sym] = value
      end
    end

    return update_params
  end

  # 发送GET/POST请求
  def self.http_request(uri,type,params)
    Rails.logger.info("#########uri: #{uri}=====type: #{type}=====params: #{params}===")
    #add by cxm 2018-03-26 errors: NameError (uninitialized constant Net::HTTP)
    require 'net/http'
    require 'uri'
    #add end by cxm 2018-03-26
    result = {}
    uri = URI.parse(uri)
    http = Net::HTTP.new uri.host, uri.port
    if uri.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
    end
    begin
      case type
        when Request_Type::GET
          request = Net::HTTP::Get.new(uri.request_uri)
        when Request_Type::POST
          request = Net::HTTP::Post.new(uri.request_uri)
      end
      request['Content-Type'] = 'application/json;charset=utf-8'
      unless params.blank?
        if params.class != 'String'
          request.body = params.to_json
        else
          request.body = params
        end
      end

      response = http.start { |http| http.request request }
      result = JSON.parse response.body
    rescue =>err
      Rails.logger.error("Data access failure.  #{err}")
      result[:status_message] = "访问数据异常!"
      result[:status_code] = ResponseStatus::Code::ERROR
    end
    return result
  end

  # 获取列表总页数
  def self.get_totalPage(total,rows)
    totalPage = 1
    if total != 0 && rows != 0
      totalPage = total % rows == 0 ? total / rows : total / rows + 1
    end
    return totalPage
  end

  # 解析JSON数据，用于直接的JSON数据解析
  def self.format_json_params(json_params)
    #格式转换为键值对格式
    if json_params.is_a?(String)
      begin
        json_params = JSON.parse(json_params)
      rescue => e
        json_params = nil
        Rails.logger.info  "JSON parse fail!"
      end
    end

    return json_params
  end

end