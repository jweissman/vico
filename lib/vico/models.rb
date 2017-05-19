# setup db
# Sequel::Model.plugin(:schema)
DB = Sequel.sqlite("db/vico.db")

unless DB.table_exists?(:space)
  DB.create_table :space do
    primary_key :id
    String :name
    String :kind
    index :name
  end
end

unless DB.table_exists?(:space_map)
  DB.create_table :space_map do
    primary_key :id
    blob :field_data
    Integer :width
    Integer :height
    foreign_key :space_id, :table => :space
  end
end

  # gather models
require 'vico/models/space'
require 'vico/models/space_map'
