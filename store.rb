require 'rubygems'
require 'json'

class Store
  attr_accessor :total_sale

  def initialize
    @items = []
    @total_sale = 0
  end

  def import_items (file)
    json_file = File.read(file)
    json_items = JSON.parse(json_file)
    json_items.each do |item|
      @items.push(Item.new(
                      item['name'],
                      item['category'],
                      item['color'],
                      item['size'],
                      item['price'],
                      item['in_store'],))
    end
  end

  def search (criterias)
    found_items = []
    exists = false
    @items.each do |item|
      criterias.each_pair do |key, value|
        if key.eql?(:available)
          if item.in_store == 0
            exists = false
          end
          break
        end
        item_value = item.send(key)
        if value.class == String
          criterias[key] = value.downcase
          item_value = item_value.downcase
        end
        if item_value.eql?(value)
          exists = true
        else
          exists = false
          break
        end
      end
      if exists
        found_items.push(item)
      end
    end
    found_items
  end

  def categories
    @items.map { |item| item.category }.uniq
  end

  def items_sorted_by(category, sort_type)
    if sort_type.eql?(:asc)
      return @items.sort { |x, y| x.send(category) <=> y.send(category) }
    end
    if sort_type.eql?(:desc)
      @items.sort { |x, y| y.send(category) <=> x.send(category) }
    end
  end

  def purchase(bought_item, quantity)
    @total_sale += (quantity * bought_item.price).round(2)
    @items.each do |item|
      if bought_item.eql?(item)
        item.in_store -= quantity
      end
    end
  end

  def unique_articles_in_category (category)
    articles = []
    search(:category => category).each do |item|
      articles.push(item.name)
    end
    articles.uniq
  end

  class Cart
    attr_accessor :items, :store

    def initialize (store)
      @store = store
      @items = []
    end

    def add_item (item, quantity = 1)
      if item.in_store > 0
        @items.push(CartItem.new(item, quantity))
      end
    end

    def checkout!
      @items.each do |cart_item|
        @store.purchase(cart_item.item, cart_item.quantity)
      end
    end

    def total_items
      total = 0
      @items.each do |item|
        total += item.quantity
      end
      total
    end

    def unique_items
      @items.each do |cart_item|
        return Array(cart_item.item)
      end
    end

    def total_cost
      cost = 0
      @items.each do |cart_item|
        cost += cart_item.item.price
      end
      cost.round(2)
    end
  end

  class Item
    attr_accessor :name, :category, :color, :size, :price, :in_store

    def initialize(name, category, color, size, price, in_store)
      @name = name
      @category = category
      @color = color
      @size = size
      @price = price
      @in_store = in_store
    end
  end

  class CartItem
    attr_accessor :quantity, :item

    def initialize(item, quantity)
      @item = item
      @quantity = quantity
    end
  end
end