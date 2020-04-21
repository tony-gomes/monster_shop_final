class CreateDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :discounts do |t|
      t.integer :percentage
      t.integer :quantity

      t.timestamps
    end
  end
end
