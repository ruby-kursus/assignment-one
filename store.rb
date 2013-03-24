# Yout little input goes here!

require 'rubygems'
require 'json'

class Store
	attr_accessor :items

	def initialize items = []
		@items = items
		@total_sales = 0
	end

	def increase_total_sale amount
		@total_sales += amount
	end

	def total_sale
		@total_sales.round(2)
	end

	def import_items file_name
		file = File.read(file_name)
		items = JSON.parse(file)

		@items = items.map { |item| Store::Item.new item }
	end

	def search(search_by)
		@items.select { |item| 
	    	search_by.all? { |k, v| 
	    		if k == :available
	    			item.in_store > 0 == v
    			else
    				value = item.send(k)

		    		if v.class == String
		    			v.casecmp(value) == 0
	    			else
		    			value == v
	    			end
    			end
			}
	    }
	end

	def items_sorted_by sort_by, sort_dir = :asc
		dir = sort_dir == :asc ? 1 : -1
		@items.sort { |item1, item2| 
			(item1.send(sort_by) <=> item2.send(sort_by)) * dir
		}
	end

	def categories
		@items.map { |item| item.category}.uniq
	end

	def unique_articles_in_category category
		@items.select { |item| item.category == category}.map { |item| item.name }.uniq
	end


	class Cart
		attr_accessor :store
		attr_reader :items

		def initialize store
			@store = store
			@items = []
		end

		def add_item item, count = 1
			[count, item.in_store].min.times { @items.push(item) }
		end

		def total_items
			@items.length
		end

		def unique_items
			@items.uniq
		end

		def total_cost
			@items.inject(0) { |sum, item| sum + item.price }.round(2)
		end

		def checkout!
			@store.increase_total_sale(total_cost)
			@items.each { |item| item.in_store -= 1 }
		end

	end

	class Item
		attr_reader :name, :category, :color, :size, :price
		attr_accessor :in_store

		def initialize(args)
			args.each do |k, v|
				instance_variable_set("@#{k}", v)
			end
		end
	end

end
