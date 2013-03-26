class Store
  attr_accessor :items_in_store, :total_sale
  attr_reader :categories

   def initialize
     @total_sale = 0
     @items_in_store = []
     @categories = []
   end
 
  def items_sorted_by(indic, que)
     if (que == :asc)
        @items_in_store.sort { |a,b| a[indic] <=> b[indic]} 
     else
        @items_in_store.sort { |a,b| b[indic] <=> a[indic]}
     end
  end        

  def unique_articles_in_category(cat)
     articles = search(:category => cat) 
     articles.map{ |item| item[:name] }.flatten.uniq
  end

  def categories 
     @items_in_store.map{ |item| item[:category] }.flatten.uniq.sort
  end

  def search(args = {}) 
     searchResults = @items_in_store.select{ |item| compare(args, item) }
  end 

  def compare(details, item)
        if details.has_key?(:available)
           return false if !(item.in_store > 0) && details[:available]
           return false if  (item.in_store > 0) && !details[:available]
        end
        details.each { |k,v| 
            valueAt_item = item[k]
            if v.is_a? String 
               return false if valueAt_item.to_s.downcase != v.to_s.downcase
            elsif k != :available
               return false if valueAt_item != v
            end
        }
     true
  end 

  def import_items(filename)
     require "json"                          #muuda stringilised võtmed objektideks
     massiiv = JSON.parse(IO.read(filename), :symbolize_names => true)
     massiiv.each do |asi|#lisab poe massiivi uue asja
        @items_in_store.push(asi)
     end
  end#last in class Store


  class Cart
    attr_accessor :items, :store, :unique_items, :total_cost, :total_items

    def initialize(args)
      @store = args
      @items = []
      @unique_items = []
      @total_cost = 0
      @total_items = 0
    end

    def add_item(asi, kogusSoovitud=1)
     kogusPoes = asi.in_store
     kogus = [kogusPoes,kogusSoovitud].min
     kogus.times {
       @items.push(asi) 
       @total_cost = (@total_cost + asi.price).round(2)
       @total_items += 1
     }
     @unique_items.push(asi) if !@unique_items.include? asi
    end
 
    def checkout!
       @items.each do |item|
          storeIndex = @store.items_in_store.index(item)
          @store.items_in_store[storeIndex][:in_store] -= 1
          @store.total_sale = (@store.total_sale + @store.items_in_store[storeIndex].price).round(2)
       end
       @items.clear
    end

  end#end of Cart
end#end of Store


class Hash
 def method_missing(n)
   self[n.to_sym]
 end
end
