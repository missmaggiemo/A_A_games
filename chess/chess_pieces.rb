# encoding: utf-8
require "colorize"

class Pieces
  attr_accessor :pos, :board
  attr_reader :color, :symbol

  def initialize(pos, board, color)
    # pos is an array [row, col] for the position of the piece on the board
    @pos, @board, @color = pos, board, color
  end

  def to_s
    "#{color.capitalize}_#{self.class}"
  end

  def moves
    raise NotImplementedError
  end

  def is_valid?(pos)
    self.moves.include?(pos)
  end

  def dup(board)
    self.class.new(@pos.dup, board, @color)
  end

  def move_into_check?(end_pos)
    board_copy = @board.board_dup
    new_piece = board_copy[self.pos]
    board_copy[self.pos] = nil
    board_copy[end_pos] = new_piece
    new_piece.pos = end_pos

    board_copy.in_check?(self.color)
  end

  def valid_moves
    self.moves.select{|move| !self.move_into_check?(move)}
  end

end

class SlidingPiece < Pieces

  def moves(options={:diag => false, :across => false})
    row, col = @pos
    end_points =[]

    if options[:diag]
      ["up-right", "up-left", "down-right", "down-left"].each do |direction|
        end_points += generate_moves(direction)
      end
    end

    if options[:across]
      ["up", "right", "down", "left"].each do |direction|
        end_points += generate_moves(direction)
      end
    end

    return end_points
  end

  def generate_moves(direction)
    row, col = @pos
    end_points =[]

    # direction will be [up-right, up-left, down-right, down-left, up, down, right, left]


    (1..7).each do |move_diff|
      case direction
      when "up-right"
        new_pos = [row - move_diff, col + move_diff]
      when "up-left"
        new_pos = [row - move_diff, col - move_diff]
      when "down-left"
        new_pos = [row + move_diff, col - move_diff]
      when "down-right"
        new_pos = [row + move_diff, col + move_diff]
      when "up"
        new_pos = [row - move_diff, col]
      when "down"
        new_pos = [row + move_diff, col]
      when "right"
        new_pos = [row, col + move_diff]
      when "left"
        new_pos = [row, col - move_diff]
      end
      break if new_pos.any? {|n| n > 7 || n < 0}
      if !@board[new_pos].nil? && @board[new_pos].color != @color
        end_points << new_pos
        break
      elsif @board[new_pos].nil?
        end_points << new_pos
      else
        break
      end
    end

    end_points
  end

end

class SteppingPiece < Pieces

  def moves
    raise "No moves!" if self.class::MOVES.empty?

    end_points = []
    row ,col = @pos[0], @pos[1]
    self.class::MOVES.each do |move|
      new_coord = [row + move[0], col + move[1]]
      if new_coord.all?{|coord| coord.between?(0,7)}
        end_points << new_coord if @board[new_coord].nil? || @board[new_coord].color != @color
      end
    end

    return end_points
  end

end

class Bishop < SlidingPiece

  def initialize(pos, board, color)
    super(pos, board,  color)
    @symbol = {:white => "♝".colorize(:light_white), :black => "♝".colorize(:black)}[color.to_sym]
  end

  def moves
    super(:diag => true)
  end

end

class Rook < SlidingPiece

  def initialize(pos, board, color)
    super(pos, board,  color)
    @symbol = {:black => "♜".colorize(:black), :white => "♜".colorize(:light_white)}[color.to_sym]
  end

  def moves
    super(:across => true)
  end
end

class Queen < SlidingPiece

  def initialize(pos, board, color)
    super(pos, board,  color)
    @symbol = {:black => "♛".colorize(:black), :white => "♛".colorize(:light_white)}[color.to_sym]
  end

  def moves
    super(:diag => true, :across => true)
  end

end

class King < SteppingPiece

  MOVES = [[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1],[0,1]]

  def initialize(pos, board, color)
    super(pos, board,  color)
    @symbol = {:black => "♚".colorize(:black), :white => "♚".colorize(:light_white)}[color.to_sym]
  end

end

class Knight < SteppingPiece

  MOVES = [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [2, -1], [-2, 1], [-2, -1]]

  def initialize(pos, board, color)
    super(pos, board,  color)
    @symbol = {:black => "♞".colorize(:black), :white => "♞".colorize(:light_white)}[color.to_sym]
  end

end

class Pawn < Pieces

  def initialize(pos, board, color)
    super(pos, board, color)
    @moves_counter = 0
    @symbol = {:black => "♟".colorize(:black), :white => "♟".colorize(:light_white)}[color.to_sym]
  end

  def pos=(new_pos)
    @pos = new_pos
    @moves_counter += 1
  end

  def moves
    # checking for off-board?
    end_points = []

    if @color == "black"
      move = [@pos[0] - 1, @pos[1]]
      end_points << move if @board[move].nil?
      if @moves_counter == 0
        move = [@pos[0] - 2, @pos[1]]
        end_points << move if @board[move].nil?
      end
    elsif @color == "white"
      move = [@pos[0] + 1, @pos[1]]
      end_points << move if @board[move].nil?
      if @moves_counter == 0
        move = [@pos[0] + 2, @pos[1]]
        end_points << move if @board[move].nil?
      end
    end

    if !check_diags.empty?
      check_diags.each {|diag| end_points << diag}
    end

    return end_points
  end

  def check_diags
    diags = []
    if @color == "black"
      if !@board[[@pos[0] - 1, @pos[1] - 1]].nil? && @board[[@pos[0] - 1, @pos[1] - 1]].color != @color
        diags << [@pos[0] - 1, @pos[1] - 1]
      end
      if
        !@board[[@pos[0] - 1, @pos[1] + 1]].nil? && @board[[@pos[0] - 1, @pos[1] + 1]].color != @color
        diags << [@pos[0] - 1, @pos[1] + 1]
      end

    elsif @color == "white"
      if !@board[[@pos[0] + 1, @pos[1] - 1]].nil? && @board[[@pos[0] + 1, @pos[1] - 1]].color != @color
        diags << [@pos[0] + 1, @pos[1] - 1]
      end
      if !@board[[@pos[0] + 1, @pos[1] + 1]].nil? && @board[[@pos[0] + 1, @pos[1] + 1]].color != @color
        diags << [@pos[0] + 1, @pos[1] + 1]
      end
    end
    diags
  end
end