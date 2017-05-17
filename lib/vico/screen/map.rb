module Vico
  module Screen
    class Map
      include Curses

      attr_reader :legend, :field

      def initialize(field:, legend:)
        @field = field
        @legend = legend
      end

      def height
        @field.length
      end

      def width
        @field[0].length
      end

      def center_x
        cols / 2
      end

      def center_y
        lines / 2
      end

      def origin_x
        center_x - width/2
      end

      def origin_y
        center_y - height/2
      end

      def draw
        return unless @field
        setpos(1,0)
        addstr("MAP SIZE: #{width}x#{height}")
        x0, y0 = origin_x, origin_y
        (0..width-1).each do |x|
          (0..height-1).each do |y|
            figure = figure_at(x,y)
            ax,ay = x + x0, y + y0
            setpos(ay,ax)
            addstr(figure)
          end
        end
        refresh
      end

      def figure_at(x,y)
        figure_for(value_at(x,y))
      end

      def value_at(x,y)
        @field[y][x]
      end

      def figure_for(value)
        case @legend[value].to_sym
        when :water then '~'
        when :land then '='
        when :city then '*'
        else '?'
        end
      end
    end
  end
end
