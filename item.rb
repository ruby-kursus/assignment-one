
class Item
	attr_accessor :name
	attr_accessor :category
	attr_accessor :color
	attr_accessor :size
	attr_accessor :price
	attr_accessor :in_store

	def initialize(options = {})
		@name = options["name"]
		@category = options["category"]
		@color = options["color"]
		@size = options["size"]
		@price = options["price"]
		@in_store = options["in_store"]
	end

end
