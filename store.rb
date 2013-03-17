require 'rubygems'
require 'json'
require 'bigdecimal'

class Store
  def initialize
    @items = []
    @purchased_items = {}
  end

  def import_items(filepath)
    data = JSON.parse(open(filepath).read())
    data.each do |row|
      @items << StoreItem.new(
          row["name"],
          row["category"],
          row["color"],
          row["size"],
          BigDecimal.new(row["price"].to_s),
          row["in_store"]
      )
    end
  end

  def categories
    @items.map(&:category).uniq
  end

  def items_sorted_by(property, sorting)
    sorted_items = @items.sort_by { |i| i.send(property) }
    sorting == :desc ? sorted_items.reverse : sorted_items
  end

  def unique_articles_in_category(category)
    search(:category => category).map(&:name).uniq
  end

  def search(criteria)
    def harmonize(value)
      case value
        when String
          return value.downcase
        else
          return value
      end
    end

    @items.select do |row|
      !criteria.map { |k, v| harmonize(row.send(k)) == harmonize(v) }.include?(false)
    end
  end

  def total_sale
    @purchased_items.map do |store_item, quantity|
      quantity * store_item.price
    end.inject(&:+) || 0
  end

  def purchase_item(store_item, quantity)
    purchased_count = @purchased_items.fetch(store_item, 0)
    @purchased_items[store_item] = purchased_count + quantity
    store_item.in_store -= quantity
  end

  class Cart
    attr_reader :store

    def initialize(store)
      @store = store
      @items = {}
    end

    def add_item(store_item, quantity = 1)
      previous_quantity = @items.fetch(store_item, 0)
      quantity = store_item.in_store < previous_quantity + quantity ? store_item.in_store - previous_quantity : quantity
      return if quantity <= 0
      @items[store_item] = previous_quantity + quantity
    end

    def checkout!
      @items.each do |store_item, quantity|
        @store.purchase_item(store_item, quantity)
      end
    end

    def items
      @items.keys
    end

    def total_items
      @items.values.inject(&:+)
    end

    def total_cost
      @items.map do |store_item, quantity|
        quantity * store_item.price
      end.inject(&:+) || 0
    end

    def unique_items
      @items.keys
    end

    class CartItem
      attr_reader :store_item, :quantity

      def initialize(store_item, quantity)
        @store_item = store_item
        @quantity = quantity
      end
    end
  end

  class StoreItem
    attr_reader :name, :category, :color, :size, :price, :in_store
    attr_writer :in_store

    def initialize(name, category, color, size, price, in_store)
      @name = name
      @category = category
      @color = color
      @size = size
      @price = price
      @in_store = in_store
    end

    def available
      @in_store > 0
    end
  end
end

