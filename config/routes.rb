Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :weixin do

    resources :verify do
      collection do
        # get 'create'
        # get 'create_menu'
      end
    end

    resources :notice_opt do
      collection do
        post 'show'
        get 'reward'
        post 'save_info'
        post 'wx_notice'
      end
    end

    resources :order do
      collection do
        get 'list'
        get 'back_list'
        post 'cashback'
        get 'capital_flow'
        post 'recharge'
      end
    end

  end

end
