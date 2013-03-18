require 'json'

class Store

	class Item < Struct.new( :name, :category, :color, :size, :price, :in_store )

		def initialize hashvalues
			values = hashvalues.values_at(:name, :category, :color, :size, :price, :in_store)
			super *values
		end

		def matches? descriptors
			descriptors.each { |key, value|
				return false if not self.send(key.to_s).to_s.downcase == value.to_s.downcase
			}
			return true
		end

		def available; self.in_store > 0; end

	end

	class Cart
		attr_accessor :store, :items

		def initialize store
			@store = store
			@items = Array.new
		end

		def add_item item, quantity = 1
			quantity.times {
				if item.available
					@items << item
					item.in_store -= 1
				end
			}
		end

		def total_cost
			total = 0
			@items.each { |item|
				total+=item.price
			}
			return total.round(2)
		end

		def unique_items; @items.uniq; end

		def total_items; @items.size; end

		def checkout!
			@store.total_sale += total_cost
			@items = Array.new
		end

	end

	attr_accessor :items, :total_sale

	def initialize
		@items = Array.new
		@total_sale = 0
	end

	public
	def import_items inputfile
		filedata = File.read(inputfile)
		items = JSON.parse(filedata, {:symbolize_names => true})
		items.each { |elem|
			storeitem = Item.new elem
			@items << storeitem
		}
	end

	def search descriptors
		@items.select { |item| item.matches? descriptors }
	end

	def items_sorted_by key, order
		sortedAsc = @items.sort_by { |elem| elem[key] }
		if order == :desc
			sortedAsc.reverse!
		end
		return sortedAsc
	end

	def categories
		items.map {|a| a.category}.uniq
	end

	def unique_articles_in_category category
		self.search(:category => category).map{ |a| a.name }.uniq
	end

end