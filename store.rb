# Yout little input goes here!
class Store
  @@items_in_store = []
  @@categories = []
     @searchResults = []
  attr_accessor :total_sale

   def initialize
     @total_sale = 0
   end
 
   def items_in_store
     @@items_in_store
   end

  def items_sorted_by(indic, que)
     if (que.to_s == "asc")
        @@items_in_store.sort { |a,b| a[indic] <=> b[indic]} 
     else
        @@items_in_store.sort { |a,b| b[indic] <=> a[indic]}
     end
  end        

  def unique_articles_in_category(cat = 'Clothing')
     unique_articles = []
     @@items_in_store.each do |itemm|
         if (itemm[:category] == cat)
           unique_articles.push(itemm[:name]) if !unique_articles.include? itemm[:name]
         end
     end
     unique_articles
  end

  def categories 
     @@categories.sort
  end

  def search(args = {}) 
     @searchResults = []
     @searchResults.clear
     searchArr = @@items_in_store
     searchArr.each do |itemm|
         c = compare(args, itemm)
         @searchResults.push(itemm) if c && (!@searchResults.include? itemm)
     end
     @searchResults
  end 

  def compare(details = {}, full = {}) 
     comp = true 
     
     if (details.has_key?(:available))
         if (full.in_store <= 0 && details.available == true)
           comp = false
         elsif (full.in_store > 0 && details.available == false)
           comp = false
         end
     end
     
        details.each { |k,v| 
         itemAt_full = full[k]
         if (k != :available)
            if v == nil
               comp = false
               break
            elsif itemAt_full.to_s.downcase != v.to_s.downcase
               comp = false
               break
            end 
         end
        }
     
     comp
  end 

#20
  def import_items(filename)
     require "json"
     massiiv = JSON.parse(IO.read(filename) )
     #lisab poe massiivi uue asja
     @@items_in_store = []
     massiiv.each do |asi|
        #muuda stringilised võtmed objektideks
        asi = asi.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
        @@items_in_store << asi
        @@categories << asi.category if !@@categories.include? asi.category
     end
  end
#last in class Store

  class Cart
    attr_accessor :items, :store, :unique_items

    def initialize(args)
      @store = args
      @items = []
      @unique_items = []
    end

    def add_item(asi, kogusSoovitud=1)
     i=0
     storeItems = @store.items_in_store
     thisItem = (@store.search(asi)).first
     storeIndex = storeItems.index(thisItem)
     kogusPoes = thisItem.in_store
     kogus = [kogusPoes,kogusSoovitud].min
     while i < kogus
       @items.push(asi)
       i += 1
       @store.items_in_store[storeIndex][:in_store] -= 1
       @store.total_sale = (@store.total_sale + @store.items_in_store[storeIndex].price).round(2)
     end
     @unique_items.push(asi) if !@unique_items.include? asi
    end

    def total_items
     @total_items = @items.size
    end

    def total_cost
     cost = 0.0
     items.each do |asi|
        cost += asi[:price]
     end
     (cost).round(2)
    end
 
    def checkout!
    end

  end#end of Cart

end#end of Store


class Hash
  def name
    self[:name]
  end
  def price
    self[:price]
  end
  def available
    self[:available]
  end
  def in_store
    self[:in_store]
  end
  def color
    self[:color]
  end
  def category
    self[:category]
  end
end
