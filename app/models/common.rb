# encoding: UTF-8
class Common

  #根据上传的json数据，获取其对应的参数
  def self.get_json_params(options)
    #测量数据的格式转换为键值对格式
    if options.is_a?(String)
      begin
        options = JSON.parse(options)
      rescue => e
        options = nil
        Rails.logger.error "JSON parse fail! params = " do
          options
        end
      end
    end

    return options
  end

  #获取文件在七牛上的url
  def self.get_url_from_qiniu(upload_type, filename)
    url = ''
    qi_niu_host_url = "http://7vikuc.com2.z0.glb.qiniucdn.com/"

    if qi_niu_host_url.present? && filename.to_s.present?
      url = qi_niu_host_url + filename.to_s
    end

    return url
  end
  #上传文件到七牛
  def self.upload_to_qiniu(file, upload_type)
    upload_flag = true

    uptoken = Common.get_qiniu_uptoken(upload_type)
    url = "http://up.qiniu.com/"

    if file.present?
      filePath = file.tempfile.path rescue file
      code, result, response_headers = Qiniu::Storage.upload_with_token_2(uptoken, filePath)
    end

    #code, result, response_headers = Qiniu::HTTP.api_post(url, {:file => file, :multipart => true, :token => uptoken}) if file.present?
    upload_flag = false if file.present? && code.present? && code != 200
    file_url = result['key'] if result.present?

    return upload_flag, file_url
  end

  #获取七牛上传凭证
  def self.get_qiniu_uptoken(upload_type = nil)

    put_policy = Qiniu::Auth::PutPolicy.new(upload_type)
    uptoken = Qiniu::Auth.generate_uptoken(put_policy)
    return uptoken
  end

  #删除七牛文件
  def self.delete_from_qiniu(upload_type, file_url)
    code, result, response_headers = Qiniu::Storage.delete(upload_type, file_url) if file_url.present?

    return code, result, response_headers
  end

end