module Vico
  # this needs to be a model...
  class SpaceMap < Sequel::Model(:space_map)
    # attr_reader :width, :height, :field
    one_to_one :space

    # deserialize field data
    def field
      field_data_elements = self.field_data.lit.to_s.split('').map(&:to_i)
      # parse field data
      Array.new(height) do
        Array.new(width) do
          field_data_elements.pop
        end
      end
    end

    # serialize field -> field data blob
    def field=(updated_field)
      self.field_data = updated_field.flatten.join
    end

    def area
      width * height
    end

    def field_with_landmarks(landmarks: [])
      begin
        augmented_field = field #.clone
        landmarks.each do |landmark|
          x,y = *landmark[:location]
          augmented_field[y][x] = landmark[:id]
          # $stdout.puts "---> Placed #{landmark[:name]} (#{landmark[:id]}) at #{x}, #{y}"
        end
        augmented_field
      rescue
        $stdout.puts $!
      end
    end

    def legend(landmarks: [])
      [ :water, :land ] + landmarks.map { |lm| lm[:name] } #(&:name)
    end

    def generate!
      self.field_data = self.class.generate_field(width, height).flatten.join
      # save
    end


    def self.generate_field(w,h)
      field = Array.new(h) do
        Array.new(w) do
          rand > 0.02 ? 1 : 0
        end
      end
      2.times { field = smooth_field(field) }
      field
    end

    def self.smooth_field(field)
      field.map.each_with_index do |row, y|
        row.map.each_with_index do |cell, x|
          # average value with surrounding cells?
          average_neighbor_value(field, x, y)
        end
      end
    end

    def self.average_neighbor_value(field, cell_x, cell_y)
      total = 0
      count = 0
      (cell_x-1..cell_x+1).each do |x|
        (cell_y-1..cell_y+1).each do |y|
          if field[y] && field[y][x]
            total += field[y][x]
            count += 1
          end
        end
      end
      (total / count).to_i
    end
  end
end
