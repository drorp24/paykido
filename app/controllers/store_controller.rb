class StoreController < ApplicationController
  def index
    @products = Product.find_products_for_sale
    @cart = find_cart
  end
  
  def add_to_cart
    product = Product.find(params[:id])
    @cart = find_cart
    @current_item = @cart.add_product(product)
    respond_to do |format|
      format.js
    end
  rescue ActiveRecord::RecordNotFound
    logger.error("Attempt to access invalid product #{params[:id]}" )
    flash[:notice] = "Invalid product"
    redirect_to_index
  end
  
  def empty_cart
    session[:cart]= nil
    flash[:notice] = "Your Cart is empty"
    redirect_to_index
  end
  
  def checkout
    @cart = find_cart
    if @cart.items.empty?
      redirect_to_index("Your Cart is Empty")
    else
      @order = Order.new
    end
  end
  
   def save_order
    @cart = find_cart
    @order = Order.new(params[:order]) 
    @order.add_line_items_from_cart(@cart) 
    if @order.save                     
      session[:cart] = nil
      redirect_to_index("Thank you for your order")
    else
      render :action => 'checkout'
    end
  end

  private
  
  def redirect_to_index(msg = nil)
    flash[:notice] = msg if msg
    redirect_to :action => 'index'
  end
  
  def find_cart
    session[:cart]||=Cart.new
  end
  
protected

  def authorize
  end
end
