module Vico
  module Screen
    class Player
      include Curses
      attr_accessor :x, :y, :name, :you
      def initialize(name:, x:, y:, you:)
        @name = name
        @x, @y = x, y
        @you = you
      end

      def draw(map:)
        x0 = x + map.origin_x
        y0 = y + map.origin_y

        setpos(y0, x0)
        addstr figure

        setpos(y0 + 1, x0 - name.length/2)
        addstr name
      end

      def figure
        @you ? '@' : '^'
      end
    end
  end
end
