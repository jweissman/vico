module Vico
  class Space < Sequel::Model(:space)
    # attr_reader :name #, :map
    one_to_one :space_map

    # def map
    #   space_map.field
    # end

    # set_schema do
    #   # text :category
    #   # foreign_key :author_id, :table => :authors
    # end
    # def initialize(name:, width: 10, height: 10)
    #   @name = name
    #   @map = SpaceMap.new(width: width, height: height)
    # end
  end
end
