# Yout little input goes here!

require 'json'

class Store
@@items
  def import_items(file_name)
    json = File.read(file_name)
    @@items = JSON.parse(json, :symbolize_names => true)
  end
  def search(keywords)
    searchable_items = @@items
    keywords.each do |kw_key, kw_value|
      if kw_key == :available && kw_value == true
          searchable_items = searchable_items.select{|item| item[:in_store] > 0}
      elsif kw_key == :available
        searchable_items = searchable_items.select{|item| item[:in_store] <= 0}
      else
        searchable_items = searchable_items.select{|item| item[kw_key].downcase == kw_value.to_s.downcase}
      end
    end
    return searchable_items
  end
end




class Cart
@@store
  def initialize(store)
   @@store = store
  end
end


class Hash
  def method_missing(n)
    self[n.to_s.to_sym]
  end
end
