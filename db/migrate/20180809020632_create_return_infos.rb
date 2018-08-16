class CreateReturnInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :return_infos,comment:'返现信息' do |t|
      t.string :wx_id,comment:'微信名'
      t.string :openid,comment:'openid'
      t.integer :platform,comment:'平台 1天猫 2京东 3淘宝'
      t.integer :order_id,comment:'订单id'
      t.string :praise_img,comment:'好评截图'
      t.integer :back_status,comment:'返现状态 1审核中 2已返现 3审核失败，请联系客服'
      t.datetime :finished_at,comment:'完成时间'

      t.timestamps
    end
    add_index :return_infos,:openid
    add_index :return_infos,:order_id
  end
end
