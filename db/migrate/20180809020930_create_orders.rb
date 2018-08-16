class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders,comment:'订单信息' do |t|
      t.string :wx_id,comment:'微信名'
      t.string :tb_id,comment:'旺旺ID'
      t.integer :platform,comment:'平台 1天猫 2京东 3淘宝'
      t.integer :status,comment:'订单状态'
      t.string :order_number,comment:'订单编号'
      t.datetime :purchase_time,comment:'购买时间'
      t.float :purchase_amount,comment:'购买金额'
      t.float :return_amount,:default => 0,comment:'返现金额'

      t.timestamps
    end
    add_index :orders,:order_number
  end
end
