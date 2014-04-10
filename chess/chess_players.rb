load "chess_board.rb"

class Player

  attr_accessor :name, :color

  def initialize(name)
    @name = name.capitalize
    @color = nil
  end

  def get_positions
    start_pos = []
    end_pos = []

    letter_to_coord = {"a" => 0, "b" => 1, "c" => 2, "d" => 3, "e" => 4, "f" => 5, "g" => 6, "h" => 7}

    puts "#{self.name}, you are #{@color}. What piece would you like to move?"
    user_start_pos = gets.chomp
    return ["quit", nil] if quit?(user_start_pos)
    user_start_pos = user_start_pos.scan(/\w/)[0, 2]
    start_pos[1] = letter_to_coord[user_start_pos[0].downcase]
    start_pos[0] = user_start_pos[1].to_i - 1

    puts "Where would you like to put it?"
    user_end_pos = gets.chomp.scan(/\w/)[0, 2]
    end_pos[1] = letter_to_coord[user_end_pos[0].downcase]
    end_pos[0] = user_end_pos[1].to_i - 1

    [start_pos, end_pos]
  end

  def quit?(user_start_pos)
    user_start_pos.downcase.split('').include?('q')
  end

end