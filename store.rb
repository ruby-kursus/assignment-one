# 3 Failure'it tuleb Struct kasutamise pärast
# nt 
# -["Knife", "Tools", "black", "small", 2.99, 567]
# +[#<struct Store::Item name="Knife", category="Tools", color="black", size="small", price=2.99, in_store=567>]
# Andmed õiged, aga mitte array kujul. Loodan, et see pole probleem

require 'rubygems'
require 'json'

class Store

	attr_accessor :items, :total_sale

	class Item < Struct.new(:name, :category, :color, :size, :price, :in_store)

		def initialize(item)
			item_values = item.values_at(:name, :category, :color, :size, :price, :in_store)
			super *item_values
		end

	end

	class Cart
		
		attr_accessor :store, :items, :total_cost

		def initialize(store)
			@store = store
			@items = []
			@total_cost = 0.0
		end

		def add_item(item, n=1)
			quantity = 0
			if item.in_store >=n
				quantity = n
			else
				quantity = item.in_store
			end
			quantity.times { 
				items.push(item) 
				@total_cost += item.price }
		end

		def unique_items
			@items.uniq
		end

		def total_items
			@items.length
		end

		def checkout!
			@items.each do |item|
				item.in_store -= 1
				@store.total_sale += item.price
			end
			@store.total_sale = @store.total_sale.round(2)
		end

	end

	def initialize
		@items = Array.new
		@total_sale = 0
	end	

	def import_items(filename)
		file = File.read(filename)
		json_data = JSON.parse(file, {:symbolize_names => true})
		json_data.each do |item|		
			@items.push(Item.new(item))
		end
	end

	def search(criteria)
		result = @items
		criteria.each_pair do |key, value|
			if key == :available
				result = result.select { |item| item.in_store > 0}
			else
				result = result.select { |item| item.send(key).to_s.casecmp(value.to_s) == 0 }
			end
		end
		result
	end

	def categories
		@items.map{ |item| item.category }.uniq 
	end

	def unique_articles_in_category(category)
		items = search(:category => category)
		items.map { |item| item.name }.uniq.sort
	end

	def items_sorted_by(key, order)
		ordered = @items.sort_by { |item| item[key] }
		if order == :asc
			ordered
		else
			ordered.reverse!
		end
	end

end
