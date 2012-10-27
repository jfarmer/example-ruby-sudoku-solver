module Sudoku
  DIMENSION = 9

  class Cell
    ALL_VALUES = (1..9).to_a

    attr_reader :value, :index
    attr_accessor :board

    def initialize(index, value, board = nil)
      @board = board

      @value = value.to_i
      @index = index
    end

    def solved?
      value > 0
    end

    def unsolved?
      !solved?
    end

    def impossible?
      unsolved? && possible_values.empty?
    end

    def possible_values
      @possible_values ||= ALL_VALUES - (row_values + column_values + grid_values)
    end

    def row
      board.row row_num
    end

    def row_values
      @row_values ||= row.map(&:value)
    end

    def column
      board.column col_num
    end

    def column_values
      @column_values ||= column.map(&:value)
    end

    def grid
      board.grid grid_num
    end

    def grid_values
      @grid_values ||= grid.map(&:value)
    end

    def to_s
      "Cell(index: #{index}, value: #{value})"
    end

    private
    def row_num
      @index / DIMENSION
    end

    def col_num
      @index % DIMENSION
    end

    def grid_num
      3*(row_num/3) + col_num/3
    end
  end

  class Board
    attr_reader :cells

    def initialize(cells)
      @columns = {}
      @rows    = {}
      @grids   = {}

      @cells = parse_cells(cells).freeze
      @cells.each do |cell|
        next if cell.solved?

        @guess_cell ||= cell

        if cell.possible_values.size == 1
          @guess_cell = cell
          break
        else
          @guess_cell = [@guess_cell, cell].min_by { |c| c.possible_values.size }
        end
      end

    end

    def row(row_num)
      @rows[row_num] ||= self.cells.slice(row_num*DIMENSION, DIMENSION)
    end

    def column(col_num)
      @columns[col_num] ||= Array.new(DIMENSION) do |i|
        self.cells[col_num + i*DIMENSION]
      end
    end

    def grid(grid_num)
      @grids[grid_num] ||= Array.new(DIMENSION) do |i|
        self.cells[9*(i/3) + i%3 + 3*(9*(grid_num/3) + grid_num%3)]
      end
    end

    def solution
      return self if self.solved?
      return nil if self.impossible?

      children.each do |child|
        ret = child.solution
        return ret if ret
      end

      return nil
    end

    def solved?
      @guess_cell.nil?
    end

    def impossible?
      cells.any?(&:impossible?)
    end

    def to_s
      cells.map(&:value).join('')
    end

    def children
      cell = @guess_cell
      index = @guess_cell.index

      cell.possible_values.map do |value|
        new_cells = cells.each_with_index.map do |cell, i|
          if i == index
            Cell.new(cell.index, value)
          else
            Cell.new(cell.index, cell.value)
          end
        end

        Board.new(new_cells)
      end
    end

    def print_board
      puts "-"*21

      (0...DIMENSION).each_slice(DIMENSION/3) do |(*args)|
        args.each do |i|
          puts(row(i).each_slice(DIMENSION/3).map do |slice|
            slice.map(&:value).join(' ')
          end.join(' | '))
        end
        puts "-"*21
      end
    end

    private
    def parse_cells(cells)
      if cells.is_a? String
        cells = cells.split('').each_with_index.map { |val, i| Cell.new(i, val) }
      end

      cells.each { |cell| cell.board = self }
    end
  end
end

def bench
  t1 = Time.now
  result = yield
  t2 = Time.now

  t2 - t1
end

File.open(ARGV[0]).each_line do |line|
  bench { Sudoku::Board.new(line.chomp).solution.print_board }.tap do |time|
    puts "Time: %0.5fs\n\n" % [time]
  end
end