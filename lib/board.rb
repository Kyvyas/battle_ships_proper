require_relative "numeric"

require 'pry'

class Board

	DEFAULT_GRID_SIZE = 10
	BASE_OFFSET = 64

	attr_reader :ships, :grid_size, :hits, :misses

	def initialize(grid_size=DEFAULT_GRID_SIZE)
		@ships = {}
		@grid_size = grid_size
		@hits = []
		@misses = []
	end

	def coordinates_for spaces, coordinate, direction
		coordinates = [coordinate]
		(spaces - 1).times do
			coordinates << (direction == :horizontal ? coordinates.last.next : next_vertical(coordinates.last))
		end
		coordinates
	end

	def next_vertical coordinate
		coordinate.reverse.next.reverse
	end

	def off_board?
		Proc.new do |coordinate|
			letter, number = coordinate.scan(/\d+|\D+/)
			(letter.ord - BASE_OFFSET) > @grid_size || number.to_i > @grid_size
		end
	end

	def place_ship(ship, direction = :vertical, coordinate)
		coordinates = coordinates_for(ship.size, coordinate.upcase, direction)
		check_if_can_place coordinates
		coordinates.each {|coordinate| ships[coordinate] = ship}
	end

	def check_if_can_place coordinates
		fail "Invalid coordinate" if coordinates.any? &off_board?
		fail "Ships cannot overlap" unless (ships.keys & coordinates).empty?
	end

	def collect_hits(position)
		@hits << position
	end

	def collect_misses(position)
		@misses << position
	end

	def checks(position)
		if ships.keys.include?(position)
			ships[position].get_hit
		end
	end

	def all_ships_sunk?
		@ships.keys.length == @hits.length
	end
end