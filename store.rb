# Yout little input goes here!

require 'json'

class Store
@@items
attr_accessor :total_sale

  def initialize
    @total_sale = 0
  end

  def import_items(file_name)
    json = File.read(file_name)
    @@items = JSON.parse(json, :symbolize_names => true)
  end

  def search(keywords)
    searchable_items = @@items
    keywords.each do |kw_key, kw_value|
      if kw_key == :available
        searchable_items = searchable_items.select{|item| item.available?}
      else
        searchable_items = searchable_items.select{|item| item[kw_key].to_s.downcase == kw_value.to_s.downcase}
      end
    end
    return searchable_items
  end

  def items_sorted_by(attribute, order)
    if order == :asc
      return @@items.sort {|x,y| x[attribute] <=> y[attribute]}
    else
      return @@items.sort {|x,y| y[attribute] <=> x[attribute]}
    end
  end

  def categories
    return @@items.map{ |item| item[:category] }.flatten.uniq
  end

  def unique_articles_in_category(category)
    articles = []
    @@items.select {|item| item[:category] == category}.map{ |item| item[:name] }.flatten.uniq.sort
  end
end


class Store::Cart
  attr_accessor :store
  attr_accessor :items

  def initialize(store)
    @store = store
    @items = []
  end

  def total_cost
    if total_items == 0
      return 0.0
    else
      return @items.map{|item| item[:price] }.flatten.inject{|sum,x| sum + x }*100.round / 100.0
    end
  end

  def add_item(item, quantity = 1)
    if quantity > item.in_store
      quantity = item.in_store
    end
    quantity.times do 
      if item.available?     
        @items << item
      end
    end
  end

  def total_items
    return @items.size
  end

  def unique_items
    return @items.uniq
  end

  def checkout!
    @items.each do |item|
      item[:in_store] -= 1
    end
    @store.total_sale += total_cost
  end
end





class Hash
  def method_missing(n)
    self[n.to_sym]
  end

  def available?
    if self.in_store > 0
      return true
    else
      return false
    end
  end
end
