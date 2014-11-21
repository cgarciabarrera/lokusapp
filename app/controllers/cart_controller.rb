class CartController < ApplicationController


  def show
    @cart = Cart.create
    @item = Item.find(1)
    @cart.add(@item,  99.99,2)

  end


end
