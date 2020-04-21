class Discount < ApplicationRecord
  validates_presence_of :percentage, :quantity, :merchant_id

  belongs_to :merchant
end
