require 'colorize'
load 'checkers/checkers_piece.rb'

class CheckersBoard
  
  attr_accessor :board_mat
  
  def initialize(fill_board = true)
    @board_mat = Array.new(8){Array.new(8){nil}}
    make_pieces if fill_board
  end
  
  
  
  def make_pieces
    @board_mat.each_with_index do |row, row_i|
      if ((0..2).to_a + (5..7).to_a).include?(row_i)
        row.each_with_index do |col, col_i|
          if row_i.even? != col_i.even?
            row_i < 3 ? color = :red : color = :black
            @board_mat[row_i][col_i] = CheckersPiece.new(color, [row_i, col_i], self)
          end
        end
      end
    end
  end
  
  
  
  def perform_move!(start_pos, end_pos)
    if self[start_pos].nil?
      raise "No piece at #{start_pos[0] + 1}, #{start_pos[1] + 1}!"
      
    elsif !self[start_pos].available_moves.include?(end_pos)
      raise "That piece can't move to #{end_pos[0] + 1}, #{end_pos[1] + 1}!"
      
    else self[start_pos].available_moves.include?(end_pos)
      piece = self[start_pos]
      piece.move_to(end_pos)
    end
  end
  
  
  def parse_moves(start_pos, end_pos)
    return [[start_pos, end_pos]] if end_pos.map.with_index {|pos, i| (pos - start_pos[i]).abs}.inject(&:+) <= 4
    
    # get sign of direction
    dir_x = (end_pos[0] - start_pos[0])/(end_pos[0] - start_pos[0]).abs
    dir_y = (end_pos[1] - start_pos[1])/(end_pos[1] - start_pos[1]).abs
    
    # get first end position in sequence
    first_end_pos = [start_pos[0] + 2 * dir_x, start_pos[1] + 2 * dir_y]
    
    # get the first move of the move sequence
    first_move = parse_moves(start_pos, first_end_pos)
    
    # get all the next moves
    first_move += parse_moves(first_end_pos, end_pos)
  end
  
  
  def perform_moves!(move_sequence) # [[[1,2], [3,4]], [[3,4], [5,6]]], each array is start_pos, end_pos
    move_sequence.each do |move|
      self.perform_move!(move[0], move[1])
    end
  end
  
  
  
  def perform_moves(move_sequence)
    silence_prints do
      new_board = self.dup
      move_sequence.each do |move|
        new_board.perform_move!(move[0], move[1])
      end
    end
    
    self.perform_moves!(move_sequence)
  end
  
  
  
  
  def [](position)
    row, col = position
    @board_mat[row][col]
  end
  
  def []=(position, new_obj)
    row, col = position
    @board_mat[row][col] = new_obj
  end

  
  def display_board
    board_numbers = '   ' + (1..8).to_a.map{|n| ' ' + n.to_s + '  '}.join('') + "\n"
    board_string = @board_mat.map.with_index do |row, row_i|
      (row_i + 1).to_s + '  ' + row.map.with_index do |piece, col_i|
        row_i.even? == col_i.even? ? background = :red : background = :black
        piece.nil? ? '    '.colorize(:background => background) : " #{piece.symbol}  ".colorize(:color => piece.color, :background => background)
      end.join('')
    end.join("\n")
    
    puts board_numbers + board_string
  end
  
  def dup
    new_board = self.class.new(false)
    
    new_board.board_mat.each_with_index do |row, row_i|
      row.each_index do |col_i|
        piece = self[[row_i, col_i]]
        new_board.board_mat[row_i][col_i] = piece.dup(new_board) unless piece.nil?
      end
    end
    
    new_board
  end
  
  
  
  def silence_prints # silence_prints do...
    begin
      orig_stderr = $stderr.clone
      orig_stdout = $stdout.clone
      $stderr.reopen File.new('/dev/null', 'w')
      $stdout.reopen File.new('/dev/null', 'w')
      loud_method = yield
    rescue Exception => e
      $stdout.reopen orig_stdout
      $stderr.reopen orig_stderr
      raise e
    ensure
      $stdout.reopen orig_stdout
      $stderr.reopen orig_stderr
    end
    loud_method
  end
  
  
end


