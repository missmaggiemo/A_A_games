class CheckersPiece
  
  attr_accessor :color, :position, :promoted, :board, :symbol
  
  def initialize(color, position, board)
    @color = color # symbol
    @position = position # [x, y]
    @promoted = false
    @board = board
    @symbol = '◉'
  end
  
  def to_s
    if self.promoted
      "king #{color.to_s} piece"
    else
      "#{color.to_s} piece"
    end
  end
  
  
  def move_to(new_pos)
    original_pos = self.position
    @board[new_pos] = self
    @board[original_pos] = nil
    self.position = new_pos
    if self.promote?
      puts "Your #{self} is now a King #{self}!" 
      self.promoted = true
    end
    if jumped?(original_pos, new_pos)
      take_piece(original_pos, new_pos)
    end
  end

  
  def available_moves
    slide_moves + jump_moves
  end
  
  
  
  def slide_moves
    moves = []
    if self.promoted
      move_diffs = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
      moves += generate_moves_from_diffs(move_diffs, jump = false)
    else
      color == :red ? move_diffs = [[1, 1], [1, -1]] : move_diffs = [[-1, 1], [-1, -1]]
      moves += generate_moves_from_diffs(move_diffs, jump = false)
    end
    
    moves 
  end
  
  def jump_moves
    moves = []
    if self.promoted
      move_diffs = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
      moves += generate_moves_from_diffs(move_diffs, jump = true)
    else
      self.color == :red ? move_diffs = [[1, 1], [1, -1]] : move_diffs = [[-1, 1], [-1, -1]]
      moves += generate_moves_from_diffs(move_diffs, jump = true)
    end
    
    moves 
  end
  
  def generate_moves_from_diffs(move_diffs, jump = false)
    moves = []
    if jump
      move_diffs.each do |diff|
        new_position = [self.position[0] + diff[0], self.position[1] + diff[1]]
        new_next_positon = [new_position[0] + diff[0], new_position[1] + diff[1]]
        next if new_position.any? {|n| n > 7 || n < 0} || new_next_positon.any?{|n| n > 7 || n < 0}
        moves << new_next_positon if !self.board[new_position].nil? && self.board[new_position].color != self.color && self.board[new_next_positon].nil?
      end
    else
      move_diffs.each do |diff|
        new_position = [self.position[0] + diff[0], self.position[1] + diff[1]]
        next if new_position.any? {|n| n > 7 || n < 0}
        moves << new_position if self.board[new_position].nil?
      end
    end
    moves
  end
  
  
  def jumped?(start_pos, end_pos)
    end_pos.map.with_index {|pos, i| (pos - start_pos[i]).abs}.inject(&:+) > 2
  end
  
  def take_piece(start_pos, end_pos)
    middle_x = start_pos[0] + (end_pos[0] - start_pos[0]) / 2
    middle_y = start_pos[1] + (end_pos[1] - start_pos[1]) / 2
    jumped_piece = self.board[[middle_x, middle_y]]
    puts "You jumped a #{jumped_piece}!" 
    self.board[[middle_x, middle_y]] = nil
    # %x( say 'Oh my god! You killed a piece! You bastard!' )
  end
  
  
  def promote?
    if self.color == :red
      self.position[0] == 7
    else
      self.position[0] == 0
    end
  end
  
  def promoted=(bool)
    @promoted = bool
    if @promoted == true
      self.symbol = '◎'
    else
      self.symbol = '◉'
    end
  end
  
  
  def dup(board)
    new_piece = self.class.new(@color, @position.dup, board)
    new_piece.promoted = @promoted
    new_piece
  end


end