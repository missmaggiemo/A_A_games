load "chess_board.rb"
load "chess_players.rb"
require "yaml"


class Game

  attr_accessor :board, :white, :black

  def initialize
    @board = Board.new
    get_players
  end

  def get_players
    system("clear")
    puts "Player 1 (white), what is your name?"
    player_input = gets.chomp
    @white = Player.new(player_input); @white.color = "white"
    puts "Player 2 (black), what is your name?"
    player_input = gets.chomp
    @black = Player.new(player_input); @black.color = "black"
  end

  def play(new = true)
    if new
      if continue_old_game?
        return nil if load_old_game
      end
    end

    loop do
      break if turn(@white) == "quit"
      break if self.game_over?
      sleep(2)

      break if turn(@black) == "quit"
      break if self.game_over?
      sleep(2)
    end

    save_game if save?
  end

  def game_over?
    if @board.checkmate?("white")
      @board.display_board
      puts "Black player won!"
      return true
    elsif @board.checkmate?("black")
      @board.display_board
      puts "White player won!"
      return true
    end
    false
  end

  def check_color(player, start_pos)
    raise "#{@board[start_pos]} isn't #{player.color}!" if @board[start_pos].color != player.color
  end

  def check_valid(start_pos, end_pos)
    return "quit" if start_pos == "quit"
    raise "Cannot choose a position off the board!" if (start_pos + end_pos).any? {|n| n < 0 || n > 7}
    raise "No piece there!" if @board[start_pos].nil?
  end

  def turn(player)
    begin
      system("clear")
      @board.display_board
      start_pos, end_pos = player.get_positions
      return "quit" if check_valid(start_pos, end_pos)
      check_valid(start_pos, end_pos)
      check_color(player, start_pos)
      @board.move(start_pos, end_pos)
    rescue => e
      puts e
      sleep(2)
      retry
    end
  end

  def save?
    puts "Do you want to save the game? Y / N"
    gets.chomp.downcase.split('').include?('y')
  end


  def save_game
    puts "Please enter the name of the file you would like to save the game to."
    filename = gets.chomp
    current_game = self.to_yaml
    File.open("saved_chess_games/#{filename}.yaml", "w"){|file| file.write(current_game)}
    return "Game saved!"
  end

  def continue_old_game?
    puts "Would you like to upload a previous file? Y/N"
    user_choice = gets.chomp
    user_choice.downcase == "y"
  end

  def load_old_game
    puts "Please enter the name of a game file to load."
    puts Dir.entries("saved_chess_games")
    file_name = gets.chomp

    YAML::load_file("saved_chess_games/#{file_name}").play(false)

    true
  end

end


Game.new.play


# def play_check
#   game = Game.new# => (Player.new("1"), Player.new("2"))
#   #game.play
#   coord_checkmate_start = [[1,5],[6,4],[1,6],[7,3]]
#   coord_checkmate_end = [[2,5],[4,4],[3,6],[3,7]]
#
#   (0..3).each do |index|
#     game.board.move(coord_checkmate_start[index], coord_checkmate_end[index])
#     game.board.display_board
#   end
#
#   game.game_over?
# end
# #
#  play_check
#




