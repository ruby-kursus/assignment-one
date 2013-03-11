
require 'rubygems'
require 'json'
require 'pp'
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
			@items.push(Item.new(:name => item['name'],
													:category => item['category'],
													:color => item['color'],
													:size => item['size'],
													:price => item['price'],
													:in_store => item['in_store']))
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
		if params.has_key?(:name)
			@found = @found.select{|f| f.name == params[:name] || params[:name] && 								f.name.casecmp(params[:name]) == 0}
		end
		if params.has_key?(:category)
			@found = @found.select{|f| f.category == params[:category] || 
							params[:category] && f.category.casecmp(params[:category]) == 0}
		end
		if params.has_key?(:color)
			@found = @found.select{|f| f.color == params[:color] || 
							params[:color] && f.color.casecmp(params[:color]) == 0}
		end
		if params.has_key?(:size)
			@found = @found.select{|f| f.size == params[:size] || 
							params[:size] && f.size.casecmp(params[:size]) == 0}
		end
		if params.has_key?(:price)
			@found = @found.select{|f| f.price == params[:price] || 
							params[:price] && f.price.casecmp(params[:price]) == 0}
		end
		if params.has_key?(:in_store)
			@found = @found.select{|f| f.in_store == params[:in_store]}
		end
		@found
	end

	class Cart
		attr_accessor :store
		attr_accessor :total_cost
		attr_accessor :items
		def initialize(store)
			@store = store
			@items = Array.new
			@total_cost = 0.00
		end

		def add_item(item)
			
		end

		def add_item(item, quantity = 1)
			i = 0
			result = @store.items.select{|a| a.name == item.name && a.color == 			 item.color 														&& a.size == item.size && a.price == item.price}
			if result.size > 0
				store_item = result[0]
				current_quantity = store_item.in_store
					while i < quantity 
						if current_quantity < 1
							break
						end
						@items.push(item)
						@total_cost += item.price
						@total_cost = @total_cost.round(2)
						i+=1
						current_quantity -=1
					end
			end
		end

		def checkout!
			@items.each do |item|
				result = @store.items.select{|a| a.name == item.name && a.color == 			 item.color 														&& a.size == item.size && a.price == item.price}
				result[0].in_store -= 1
			end
			@store.total_sale += @total_cost
		end

		def total_items
			@items.size
		end

		def unique_items
			@items.uniq{|a| a.name && a.category && a.color && a.size && a.price}
		end
	end
end

