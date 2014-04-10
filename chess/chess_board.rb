# encoding: utf-8

load 'chess_pieces.rb'
require "colorize"

class Board

  attr_accessor :board_array

  def initialize(fill_board = true)
    #Array.new(8){Array.new(8){nil}}
      blank_board
      board_generate if fill_board
  end

  def blank_board
    @board_array = Array.new(8){Array.new(8){nil}}
  end

  def board_generate
#    @board_array = Array.new(8){Array.new(8){nil}}

    generate_pieces('black')
    generate_pieces('white')
  end

  def generate_pieces(color)

    if color == "white"
      row = 0
      pawn_row = 1
    elsif color == "black"
      row = 7
      pawn_row = 6
    end

    @board_array[row][0] = Rook.new([row,0], self, color)
    @board_array[row][1] = Knight.new([row,1], self, color)
    @board_array[row][2] = Bishop.new([row,2], self, color)
    @board_array[row][3] = Queen.new([row,3], self, color)
    @board_array[row][4] = King.new([row,4], self, color)
    @board_array[row][5] = Bishop.new([row,5], self, color)
    @board_array[row][6] = Knight.new([row, 6], self, color)
    @board_array[row][7] = Rook.new([row,7], self, color)

    (0..7).each {|col| @board_array[pawn_row][col] = Pawn.new([pawn_row,col], self, color) }
  end

  def in_check?(color)
    opp_color = (["black", "white"] - [color]).first

    opp_color_pieces = find_pieces(opp_color)

    king = find_king(color)
    king_posn = king.pos

    opp_color_pieces.each do |opp_piece|
       return true if opp_piece.is_valid?(king_posn)
    end

    return false
  end

  def find_pieces(color)
    @board_array.flatten.select{|piece| !piece.nil? && piece.color == color}
  end

  def find_king(color)
    @board_array.flatten.select{|piece| piece.class.to_s == "King" && piece.color == color}.first
  end

  def board_dup
    new_board = self.class.new(false)
    all_pieces = find_pieces("white") + find_pieces("black")
    all_pieces.each {|piece| new_board[piece.pos] = piece.dup(new_board)}
    return new_board
  end


  def [](pos)
    row, col = pos
    @board_array[row][col]
  end

  def []=(pos, new_obj)
    row, col = pos
    @board_array[row][col] = new_obj
  end


  def move(start, end_pos)
    if self[start].nil?
      raise "No piece at the start position."
    elsif self[start].move_into_check?(end_pos)
      raise "Can't move yourself into check!"
    elsif self[start].is_valid?(end_pos)
      puts "#{self[start]} takes #{self[end_pos]}!" if !self[end_pos].nil?
      self[start].pos = end_pos
      self[end_pos] = self[start]
      self[start] = nil
    else
      raise "Can't move there."
    end

  end

  def checkmate?(color)
    color_pieces = find_pieces(color)
    color_pieces.all?{|piece| piece.valid_moves.empty?}
  end

  def display_board
    colors = [:white, :light_black]
    color = 0
    cols = "  " + ('A'..'H').to_a.join("  ").colorize(:light_white) + "\n"
    board_display = @board_array.map.with_index do |row, row_i|
      color = (color == 1 ? 0 : 1)
      (row_i + 1).to_s.colorize(:light_white) + " " + row.map do |piece|
        color = (color == 1 ? 0 : 1)
        if !piece.nil?
          (" " + piece.symbol + " ").colorize(:background => colors[color])
        else
          "   ".colorize(:background => colors[color])
        end
      end.join("")
    end.join("\n")

    puts cols + board_display
  end
end


