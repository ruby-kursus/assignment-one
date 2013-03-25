#encoding: utf-8

require 'rubygems'
require 'json'

class Store
	attr_accessor :items, :total_sale

	def initialize *args
		super *args
    @items = []
		@total_sale=0
	end

	def import_items(filename)
		file = open(filename)
		parsed = JSON.parse(file.read)
		parsed.each do |item|
      search_item = item.reject {|key,value| key == "in_store" }
      found_item_list= @items.select { |i| i.includes_hash?(search_item)}
      found_item=item
      if found_item_list!=[]
        found_item=found_item_list.first
        @items.delete(found_item)
        found_item["in_store"]+=item["in_store"]
      end
      @items.push(item)
		end	
	end
	def search(item = {})
    @items.select { |i| i.includes_hash?(item)}
	end

	def items_sorted_by(label,direction)
		sorted=@items.sort_by{ |i| i["#{label}"] }
		if direction == :desc
			sorted=sorted.reverse
		end
		sorted
	end

	def categories
		@items.inject([]) { |result,i| result << i["category"] unless result.include?(i["category"]); result }	
	end
	
	def unique_articles_in_category(category)
		@items.inject([]) { |articles,i| articles << i['name'] unless i['category'] != category || articles.include?(i['name']); articles }
	end
	def total_sale
		@total_sale.round(2)
	end
	class Cart < Struct.new(:store)
		attr_accessor :items_in_cart,:store
		def initialize(store)
      @store=store;
			@items_in_cart=[]
		end
		def store
			@store	
		end

		def items
			@items_in_cart
		end

		def total_cost
			@items_in_cart.inject(0.0) { |result,i| result + i["price"]*i["quantity"]}.round(2)
		end

		def total_items
			@items_in_cart.inject(0) { |result,i| result + i["quantity"]}	
		end
    
    
		def add_item(item, quantity = 1)
      if @store.search(item) != []
        found_item_list= @items_in_cart.select { |i| i.includes_hash?(item)}
        found_item=item.dup
        if found_item_list==[]
          quantity = item["in_store"] unless item["in_store"]>quantity
        else
          found_item=found_item_list.first.dup
          @items_in_cart.delete(found_item)
          quantity = quantity + found_item["quantity"]
          quantity = item["in_store"] unless item["in_store"]>quantity
        end
        found_item["quantity"]=quantity
        if found_item["quantity"] != 0
          @items_in_cart.push(found_item)
        end
      end
    end
    def unique_items
      @items_in_cart.inject([]) { |result,i| result << i.reject {|key,value| key == "quantity" }}
    end

    def checkout!
      @store.total_sale = total_cost;
      @items_in_cart.each {|i| checkout_item(i)}
      @items_in_cart=[]
    end
    
    def checkout_item(item)
        search_item=item.reject {|key,value| key == "quantity" }
        found_item= @store.items.select { |i| i.includes_hash?(search_item)}.first
        found_item["in_store"]-=item["quantity"]
    end
  end
end

class Hash
  def category
    self["category"]
  end
  def color
    self["color"]
  end
  def size
    self["size"]
  end
  def in_store
    self["in_store"]
  end
  def price
    self["price"]
  end
  def name
    self["name"]
  end
  
  def includes_hash?(other)
    included = true
    other.each do |key, value|
      if key == :available
        if value && self["in_store"] > 0 || !value && self["in_store"] == 0
          include&=true
        else
          return false
        end
      elsif self["#{key}"].is_a?(String) && value.is_a?(String)
        included &= self["#{key}"].casecmp(value) == 0
      else
        included &= self["#{key}"] == value
      end
    end
    included
  end
end


def test(var="",extra="")
  puts "#{var}: #{extra}"
end