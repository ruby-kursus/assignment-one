require 'rubygems'
require 'json'

require_relative 'store'

require 'minitest/autorun'

class TestStore < MiniTest::Unit::TestCase
  def setup
    @store = Store.new
    @store.import_items('items.json')
    @cart = Store::Cart.new(@store)
    @default_item = @store.search(:name => 'Knife', :size => 'small').first
  end

  def test_search_by_multiple_search_criteria
    assert_equal 2, @store.search(:color => 'blue', :name => 'jeans').size
  end

  def test_search_for_non_present_items
    assert_equal [], @store.search(:color => 'green', :size => nil)
  end
  
  def test_search_with_availability_flag
    assert_equal 'A lamp', @store.search(:color => 'green', :category => 'furniture', :available => true).first.name
  end
  
  def test_sort_items_by_price_cheapest_first
    assert_equal 1.99, @store.items_sorted_by(:price, :asc).first.price
  end
  
  def test_sort_items_by_in_stock_cheapest_last
    assert_equal 399.00, @store.items_sorted_by(:price, :desc).first.price
  end
  
  def test_categories_list
    assert_equal ['Clothing', 'Furniture', 'Tools'], @store.categories
  end
  
  def test_unique_items_in_category
		#Modifitseerisin seda, sest eelnev test ei olnud päris korrektne
		@res = @store.unique_articles_in_category('Clothing') 
    assert_equal 2, @res.size
		assert_includes @res, "T-shirt"
		assert_includes @res, "Jeans"
  end
  
  def test_cart_initialization
    assert_equal @store, @cart.store
    assert_equal [], @cart.items
    assert_equal 0.0, @cart.total_cost
  end
  
  def test_add_one_item_into_cart
    @cart.add_item(@default_item)
    assert_equal 1, @cart.total_items
    assert_equal Array(@default_item), @cart.unique_items
    assert @cart.unique_items.include?(@default_item)
  end
   
  def test_add_one_item_multiple_times_into_cart
    n = 5
    n.times { @cart.add_item(@default_item) }
    assert_equal n, @cart.total_items
    assert_equal Array(@default_item), @cart.unique_items
    assert_equal 14.95, @cart.total_cost
  end

  def test_add_item_with_quantity_into_cart
    @cart.add_item(@default_item, 5)
    assert_equal 5, @cart.total_items
    assert_equal Array(@default_item), @cart.unique_items
  end
   
  def test_add_item_multiple_items_into_cart
    n = 2
    n.times { @cart.add_item(@default_item) }
    @cart.add_item(@store.search(:name => 'Hammer').first)
    assert_equal n + 1, @cart.total_items
    assert_equal 11.97, @cart.total_cost
  end
 
  def test_out_of_stock_items_cant_be_added_to_cart
    out_of_stock_item = @store.search(:in_store => 0).first
    @cart.add_item(out_of_stock_item)
    assert_equal [], @cart.items
    assert_equal 0.0, @cart.total_cost
  end
 
  def test_cant_add_more_than_than_in_stock
    last_item_in_stock = @store.search(:in_store => 1).first
    @cart.add_item(last_item_in_stock, 3)
    assert_equal last_item_in_stock.price, @cart.total_cost
  end
  
  def test_checkout_to_reduce_items_in_stock
    previously_in_store = @default_item.in_store
    @cart.add_item(@default_item)
    @cart.checkout!
    assert_equal previously_in_store - 1, @default_item.in_store
  end

  
  def test_initial_total_sale
    assert_equal 0, @store.total_sale
  end
  
  def test_checkout_to_increase_total_sales
    n = 5
    @cart.add_item(@default_item, n)
    @cart.checkout!
    assert_equal @store.total_sale, (@default_item.price * n).round(2)
  end
end
