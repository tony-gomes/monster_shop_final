class Merchant::DiscountsController < Merchant::BaseController
  def index
    @discounts = Discount.all
    @discount = Discount.new
  end

  def create
    merchant = current_user.merchant
    @discount = merchant.discounts.create(discount_params)
    if @discount.save
      redirect_to "/merchant/discounts"
    else
      generate_flash(discount)
      render :new
    end
  end

  def edit
    @discount = current_user.merchant.discounts.find(params[:id])
  end

  def update
    @discount = current_user.merchant.discounts.find(params[:id])
    @discount.update(discount_params)
    if @discount.update(discount_params)
      redirect_to "/merchant/discounts"
    else
      generate_flash(discount)
      render :edit
    end
  end

  def destroy
    discount = Discount.find(params[:id])
    discount.destroy
    redirect_to "/merchant/discounts"
  end

  private

  def discount_params
    params.require(:discount).permit(:percentage, :quantity)
  end
end
