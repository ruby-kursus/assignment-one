require 'rubygems'
require 'json'

class Item
  attr_accessor :name, :size, :color, :category, :in_store, :available, :price

  def initialize(item)
     @name=item["name"]
     @size=item["size"]
     @color=item["color"]
     @category=item["category"]
     @price=item["price"]
     @in_store=item["in_store"]
     @available=item["available"]
  end
end

class Store
  attr_writer :total_sale

  def initialize
    @total_sale = 0.0
  end

  def total_sale
    @total_sale.round(2)
  end

  def import_items(file_name)
    @items = []
    JSON.parse(File.read(file_name)).each {|i| 
      @items << Item.new(i)
    }
  end

  def search(options)
    items = @items

    options.each { |key,value|
      if key == :available
        items = items.select {|item| item.in_store > 0}
      elsif key == :in_store
        items = items.select {|item| item.in_store == value.to_f}
      else
        items = items.select {|item| item.send(key).downcase == value.to_s.downcase}
      end
    }
    return items
  end

  def items_sorted_by(symb, order)
    if order == :asc
      @items.sort_by { |item| item.send(symb.to_s) }
    else
      @items.sort_by { |item| item.send(symb.to_s) }.reverse
    end 
  end

  def categories
    cat = []
    @items.uniq { |i| i.category }.each do |c|
      cat << c.category
    end
    return cat
  end

  def unique_articles_in_category(category)
    ui = []
    @items.select {|item| item.category == category}.uniq { |i| i.name}.each do |c|
      ui << c.name
    end
    return ui
  end

  class Cart
    attr_accessor :store, :items, :total_cost

    def initialize(store)
      @store = store
      @items = []
      @total_cost = 0.0
    end

    def add_item(item, qty=1)
      qty.times{
        if item.in_store > 0
          @items << item
          item.in_store -= 1
        end
      }
      return @itmes  
    end

    def total_items
      @items.size
    end

    def unique_items
      @items.uniq
    end

    def total_cost
      @items.each do |item|
        @total_cost += item.price.to_f 
      end
      @total_cost.round(2)
    end

    def checkout!
      @items.each do |item|
        @store.total_sale += item.price.round(2)
      end
    end
  end
end

=begin
s1 = Store.new
s1.import_items('items.json')
c1 = Store::Cart.new(s1)
last_item_in_stock = s1.search(:in_store => 1).first
c1.add_item(last_item_in_stock, 3)
puts last_item_in_stock.name
puts last_item_in_stock.price
puts last_item_in_stock.in_store
=end
