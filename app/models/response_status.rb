#encoding: utf-8

#
# 接口响应状态
#
class ResponseStatus

  module Code

    SUCCESS = '20000'

    # 4xxxx
    INVALID_REQUEST = '40300'

    INVALID_TERMINAL_SESSION_KEY = '40301'

    INVALID_USER_SESSION_KEY = '40302'


    EXCEED_REQUEST_LIMIT = '40303'

    NOT_COMPATIBLE_REVISION = '40304'

    # 5xxxx

    ERROR = '50000'

    # request module  500xx
    MISS_REQUEST_PARAMS = '50001'

    # business process error
    DATA_PROCESS_ERROR = '51000'

    DATA_MISS_ERROR = '51001'

  end

end