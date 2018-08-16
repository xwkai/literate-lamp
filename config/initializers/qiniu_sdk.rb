#!/usr/bin/env ruby

require 'qiniu'
require "qiniu/http"

Qiniu.establish_connection! :access_key => 'fLrplXGXx2AvBVNQA4Jy-X7W17tACrI9gzlWoyl9',
                            :secret_key => 'cmeGBp3wFIhS70pAqrYIEasEFnauiIaZ26OUg4Lr',
                            :mime_limit => 'image/*', #只允许上传图片类型
                            :fsize_limit  => '5242880' #最大允许上传5M  1048576*5