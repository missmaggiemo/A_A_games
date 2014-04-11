load 'checkers/checkers_board.rb'
load 'checkers/checkers_player.rb'
require 'date'
require 'yaml'

class CheckersGame
  
  attr_accessor :black, :red, :board, :filename
  
  def initialize
    @board = CheckersBoard.new
    @black = nil
    @red = nil
    @filename = "Checkers_#{@black}&#{@white}_" + DateTime.now.to_s.gsub(":", "_") + ".yaml"
  end
  
  def get_players
    system('clear')
    puts "Player 1 (black), what is your name?"
    @black = CheckersPlayer.new(gets.chomp, :black)
    puts "Player 2 (red), what is your name?"
    @red = CheckersPlayer.new(gets.chomp, :red)
  end
  
  
  def play(new = true)
    system('clear')
    if new
      if continue_old_game?
        return nil if load_old_game
      end
    end  
    
    get_players if @black.nil? || @red.nil?
      
    loop do
      begin
        break if turn(@black) == :quit
        break if game_over?
      rescue => e
        puts e
        sleep(1)
        retry
      end
      sleep(1)
      begin
        break if turn(@red) == :quit
        break if game_over?
      rescue => e
        puts e
        sleep(1)
        retry
      end
      sleep(1)
    end
    
    unless game_over?
      save_game if save?
    end
    "Thanks for playing Checkers!"
  end
  
  
  def turn(player)
    system('clear')
    self.board.display_board
    start_pos = player.get_start_pos
    
    return :quit if start_pos == :quit
    raise "There's no piece there!" if self.board[start_pos].nil?
    raise "That's not your piece!" if self.board[start_pos].color != player.color
    
    end_pos = player.get_end_pos
    return :quit if end_pos == :quit
    
    move_sequence = self.board.parse_moves(start_pos, end_pos)
    
    self.board.perform_moves(move_sequence)
  end
  
  
  
  
  def game_over?
    [:red, :black].any? do |color|
      @board.board_mat.flatten.none? {|piece| !piece.nil? && piece.color == color}
    end
  end

  
  
  
  
  
  
  
  def save?
    save_response = ''
    while save_response.empty?
      puts "\nSave this game? Y / N"
      user_response = gets.chomp.upcase
      if %w(N Y YES NO).include? user_response
        save_response = user_response
      else
        puts "Response must be Y or N.".colorize(:light_red)
      end
    end
    save_response.split('').include?("Y")
  end
  
  def save_game
    serialized = self.to_yaml
    File.open("checkers/saved_games/#{self.filename}", "w") {|file| file.write(serialized)}
    puts "\nThanks for playing Checkers!"
  end
  
  def continue_old_game?
    new_old = ''
    while new_old.empty?
      puts "Would you like to start a new game or continue an old game? NEW  OLD"
      user_decision = gets.chomp.upcase
      if %w(NEW OLD N O).include?(user_decision)
        new_old = user_decision
      else
        puts "Please respond with NEW or OLD.".colorize(:light_red)
      end
    end
  
    new_old.split('').include?('O')
  end
  
  def load_old_game
    old_game = ''
    games = Dir.entries("checkers/saved_games")
    while old_game.empty?
      puts "\nPlease choose a game file to load:"
      puts games
      user_response = gets.chomp
      if games.include? user_response
        old_game = user_response
      else
        puts "Game not found. Are you sure you spelled the file name correctly?".colorize(:light_red)
      end
    end
  
    YAML::load_file("checkers/saved_games/#{old_game}").play(new = false)
  
    return true
  
  end
  
end



CheckersGame.new.play




