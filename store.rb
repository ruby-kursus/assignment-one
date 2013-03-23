# Yout little input goes here!
require 'json'

class Hash
  def price
    return self[:price]
  end
  def name
    return self[:name]
  end
  def in_store
  	return self[:in_store]
end

end

class Store
	attr_accessor :total_sale

	class Cart
		attr_accessor :store
		attr_accessor :items
		attr_accessor :cost

		def initialize(store)
			@store = store
			@items = Array.new()
			@cost = 0.0
		end

		def add_item( item, arv = 1 )
			if item[:in_store] > 0
				if item[:in_store] < arv
					item[:in_store].times{@items << item; @cost += item[:price]}
				else
					arv.times{@items << item; @cost += item[:price]}
				end
			end
		end

		def total_items
			return @items.size
		end

		def unique_items
			return @items.uniq()
		end

		def total_cost
			return @cost.round(2)
		end

		def checkout!
			@items.each do |item|
            	item[:in_store] -= 1
            	item[:in_store] > 0 ? item[:available] = true : item[:available] = false
        	end
        	@store.total_sale += self.total_cost
		end
	end

	def initialize()
		@esemed = Array.new()
		@total_sale = 0
	end

	def import_items(json)
		items = JSON.parse(File.read(json))
		items.each do |item|
            ese = item.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
            ese[:in_store] > 0 ? ese[:available] = true : ese[:available] = false
            @esemed.push(ese)
        end
	end

	def match(hash = {})
		hash.each do |k,v|
			item.send[:k]
		end
	end

	def search(params)
		x = Array.new()
		@esemed.select{|item| x << item if item.values_at(*params.keys).map{|ese| (ese.is_a? String) ? ese.downcase : ese} == \
		params.values_at(*params.keys).map{|ese| (ese.is_a? String) ? ese.downcase : ese}}
		return x
	end

	def items_sorted_by(veerg, asc = :asc)
		if(asc == :asc)
			return @esemed.sort_by { |hash| hash[veerg] }
		else
			return @esemed.sort_by { |hash| hash[veerg] }.reverse
		end
	end

	def categories()
		@esemed.inject([]){ |result,h| result << h[:category]\
		unless result.include?(h[:category]);\
		result }
	end

	def unique_articles_in_category(category)
		@esemed.inject([]){ |result, ese| result << ese[:name]\
		if ese[:category] == category;\
		result}.uniq()
	end

end

# store = Store.new
# cart = Store::Cart.new(store)
# store.import_items('items.json')
# puts store.search(:color => 'green', :category => 'furniture', :available => true).first