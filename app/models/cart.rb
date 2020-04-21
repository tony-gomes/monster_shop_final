class Cart
  attr_reader :contents

  def initialize(contents)
    @contents = contents || {}
    @contents.default = 0
  end

  def add_item(item_id)
    @contents[item_id] += 1
  end

  def less_item(item_id)
    @contents[item_id] -= 1
  end

  def count
    @contents.values.sum
  end

  def items
    @contents.map do |item_id, _|
      Item.find(item_id)
    end
  end

  def grand_total
    grand_total = 0.0
    @contents.each do |item_id, _quantity|
      grand_total += subtotal_of(item_id)
    end
    grand_total
  end

  def count_of(item_id)
    @contents[item_id.to_s]
  end

  def subtotal_of(item_id)
    @item = Item.find(item_id)
    @item_price = Item.find(item_id).price
    @cart_quantity = @contents[item_id.to_s]
    merchant = Merchant.find(@item.merchant_id)
    @discount = get_merchant_discount(merchant, @cart_quantity)

    if @discount
      get_discounted_subtotal(@discount.percentage, @cart_quantity, @item_price)
    else
      @item.price * @cart_quantity
    end
  end

  def get_discounted_subtotal(discount, quantity, price)
    prediscount_subtotal = price * quantity
    discount_dollars = prediscount_subtotal * (discount / 100.0)
    new_subtotal = prediscount_subtotal - discount_dollars
    new_subtotal
  end

  def get_merchant_discount(merchant, cart_quantity)
    current_discounts = merchant.discounts.select {|discount| cart_quantity >= discount.quantity}
    valid_discount = current_discounts.max_by {|d| d.percentage }
    valid_discount
  end

  def limit_reached?(item_id)
    count_of(item_id) == Item.find(item_id).inventory
  end
end
