class CreateCapitals < ActiveRecord::Migration[5.2]
  def change
    create_table :capitals,comment:'资金流水' do |t|
      t.string :flow_number,comment:'流水号'
      t.integer :order_id,comment:'订单id'
      t.datetime :time,comment:'记录日期'
      t.integer :platform,comment:'平台 1天猫 2京东 3淘宝'

      t.timestamps
    end
  end
end
