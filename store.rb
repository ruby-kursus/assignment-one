
require 'rubygems'
require 'json'
require './item.rb'

class Store
	attr_accessor :items
	attr_accessor :total_sale

	def initialize
		@items = Array.new
		@total_sale = 0.0
	end

	def import_items(file_name)
		json = File.read(file_name)
		items_json = JSON.parse(json)
		items_json.each do |item|
			@items.push(Item.new(item))
		end
	end

	def categories
		@items.collect{|a| a.category}.uniq
	end

	def unique_articles_in_category(category_name)
		@items.select{|a| a.category == category_name}.collect{|a| a.name}.uniq
	end

	def items_sorted_by(category_type, sort_type)
		sort_type == :asc ? @items.sort_by{|a| a.send(category_type)} : 
			@items.sort_by{|a| a.send(category_type)}.reverse
	end

	def search(params = {})
		@found = @items
		params.each_pair do |key, value|
			if key == :available
				@found = @found.select{|f| f.in_store > 0}
			else
				@found = @found.select{|f| f.send(key).to_s.casecmp(value.to_s) == 0}
			end
		end
		@found
	end

	class Cart
		attr_accessor :store
		attr_accessor :items
		def initialize(store)
			@store = store
			@items = []
		end

		def add_item(item, qty = 1)
			qty.times do
				@items << item if @items.select{|a| a == item}.size < item.in_store
			end
		end

		def total_cost
			sum = 0.0
			items.each do |i|
				sum += i.price.to_f
			end
			sum.round(2)
		end

		def checkout!
			@items.each do |item|
				item.in_store -= 1
			end
			@store.total_sale += total_cost
		end

		def total_items
			@items.size
		end

		def unique_items
			@items.uniq
		end
	end
end

