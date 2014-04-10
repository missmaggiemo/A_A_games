require 'colorize'
require 'yaml'

class Minesweeper
  
  attr_accessor :grid, :checked, :flagged, :action, :cursor, :user_position, :bomb_positions, :bomb
  
  def initialize
    @checked = [] # array of [i, j] arrays to indicate 'checked' squares
    @flagged = [] # array of [i, j] arrays to indicate 'flagged' squares
    @action = ''
    @cursor = [0,0]
    @user_position = []
    @bomb_positions = []
    @bomb = false
    @file_name = "Minesweeper_" + DateTime.now.to_s.gsub(":", "_") + ".yaml"
    @level = nil
  end
  
  

  def play(new = true)
    system("clear")
    if new == true
      if continue_old_game?
        return nil if load_old_game
      end
    end
    get_level
    generate_grid(@level)
    loop do
      system("clear")
      display_grid
      get_action
      break if quit?
      get_position
      do_action
      puts "You flagged all the bombs! Congratulations!" if win?
      break if lose? || win?
    end
    save_game
  end
  
  
  def get_level
    while @level.nil?
      puts "What level would you like to play at? EASY  MEDIUM  HARD  MAXIMUM"
      user_level = gets.chomp.upcase
      if %w(EASY MEDIUM MED HARD MAXIMUM MAX).include?(user_level)
        case user_level
        when "EASY"
          @level = 9
        when "MED" || "MEDIUM"
          @level = 15
        when "HARD"
          @level = 20
        when "MAX" || "MAXIMUM"
          @level = 40
          puts "YOU CHOSE MAXIMUM!!!!! PREPARE FOR A HEADACHE!!!!".colorize(:red)
        end
      end
    end  
  end
  
  
  def generate_grid(level = 9)
    case level
    when 9
      grid = Array.new(level){Array.new(level){[0, 0, 0, 0, 0, "☹"].sample}}
    when 15
      grid = Array.new(level){Array.new(level){[0, 0, 0, 0, "☹"].sample}}
    when 20
      grid = Array.new(level){Array.new(level){[0, 0, 0, "☹"].sample}}
    when 40
      grid = Array.new(level){Array.new(level){[0, 0, "☹"].sample}}
    end
      
    grid.each_index do |row|
      grid.each_index do |col|
        if grid[row][col] == "☹"
          
          @bomb_positions << [row, col]
          
          grid[row][col + 1] += 1 if !grid[row][col + 1].nil? && grid[row][col + 1] != "☹"
          grid[row][col - 1] += 1 if !grid[row][col - 1].nil? && grid[row][col - 1] != "☹"
          
          if !grid[row + 1].nil?
            grid[row + 1][col] += 1 if !grid[row + 1][col].nil? && grid[row + 1][col] != "☹"
            grid[row + 1][col + 1] += 1 if !grid[row + 1][col + 1].nil? && grid[row + 1][col + 1] != "☹"
            grid[row + 1][col - 1] += 1 if !grid[row + 1][col - 1].nil? && grid[row + 1][col - 1] != "☹"
          end
          if !grid[row - 1].nil?
            grid[row - 1][col] += 1 if !grid[row - 1][col].nil? && grid[row - 1][col] != "☹"
            grid[row - 1][col + 1] += 1 if !grid[row - 1][col + 1].nil? && grid[row - 1][col + 1] != "☹"
            grid[row - 1][col - 1] += 1 if !grid[row - 1][col - 1].nil? && grid[row - 1][col - 1] != "☹"
          end
          
        end
      end
    end
    @grid = grid
  end
  
  def display_grid(cursor = false)
    display_grid = Array.new(@level){Array.new(@level){'░'}}
    if !@checked.empty?
      @checked.each do |i, j|
        display_grid[i][j] = @grid[i][j]
        display_grid[i][j] = '_' if @grid[i][j] == 0
      end
    end
    if !@flagged.empty?
      @flagged.each do |i, j|
        display_grid[i][j] = "⚑".colorize(:light_yellow)
      end
    end
    if cursor
      case @action
      when "FLAG"
        display_grid[@cursor[0]][@cursor[1]] = "⚑".colorize(:light_cyan)
      when "UNFLAG"
        display_grid[@cursor[0]][@cursor[1]] = "x".colorize(:light_cyan)
      when "REVEAL"
        display_grid[@cursor[0]][@cursor[1]] = "⎕".colorize(:light_cyan)
      end
    end
    
    readout = "\n" + display_grid.map.with_index {|row, i| row.map(&:to_s).join("  ") + " \n" }.join("") + ""
    
    readout = readout + "\nPress [return] three times to #{@action}." if cursor
    
    puts readout
  end
  
  
  def get_action
    @action = ''
    while @action.empty?
      puts "\nWhat would you like to do? FLAG  UNFLAG  REVEAL  QUIT"
      user_action = gets.chomp.upcase
      if %w(FLAG UNFLAG REVEAL QUIT Q).include?(user_action)
        @action = user_action
      else 
        puts("Action must be FLAG, UNFLAG, REVEAL, or QUIT.".colorize(:light_red))
      end
    end
  end
  
  def quit?
    @action.split('').include?('Q')
  end
  
  
  def get_position
    @cursor = [0,0]
    # cursor position is... light_cyan
    set_cursor = false
    update_cursor = [0,0]
    
    until set_cursor
      system("clear")
      display_grid(cursor = true)
      begin
        system("stty raw -echo")
        user_key = IO.read '/dev/stdin', 3
      ensure
        system("stty -raw echo")
      end
      # user_key = STDIN.noecho(&:gets).chomp
      # p user_key
      if user_key == "\r\r\r"
        set_cursor = true
        @user_position = @cursor
      else
        user_key = user_key.scan(/\e\[\w/).first
        if ["\e[A", "\e[B", "\e[D", "\e[C"].include?(user_key)
          case user_key
          when "\e[A"
            @cursor[0] -= 1 if @cursor[0] > 0
          when "\e[B"
            @cursor[0] += 1 if @cursor[0] < @level - 1
          when "\e[D"
            @cursor[1] -= 1 if @cursor[1] > 0
          when "\e[C"
            @cursor[1] += 1 if @cursor[1] < @level - 1
          end
        end
      end
    end
  end
  
  
  def do_action
    if @action == "FLAG"
      @flagged << @user_position
    elsif @action == "UNFLAG"
      @flagged = @flagged - [@user_position]
    elsif @action == "REVEAL"
      if @bomb_positions.include?(@user_position)
        @bomb = true
        puts "\nDANGER DANGER DANGER\n\n\n\nA bomb exploded. You lose!".colorize(:red)
      else
        update_checked(@user_position)
      end
    end
  end
  
  def update_checked(position) # [x, y] position
    
    return nil if @checked.include?(position) || @bomb_positions.include?(position)
    
    row = position[0]
    col = position[1]
    
    @checked << position if @grid[row][col] != "☹"

    update_checked([row, col + 1]) if !@grid[row][col + 1].nil?
    update_checked([row, col - 1]) if !@grid[row][col - 1].nil? && col - 1 > 0
    
    if !@grid[row + 1].nil?
      update_checked([row + 1, col]) if !@grid[row + 1][col].nil?
    end
    if !@grid[row - 1].nil? && row - 1 > 0
      update_checked([row - 1, col]) if !@grid[row - 1][col].nil?
    end
    
  end
  
  def lose?
    @bomb
  end
  
  def win?
    @bomb_positions.sort == @flagged.sort
  end
  
  def save_game
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
    
    if save_response.split('').include?("Y")
      serialized = self.to_yaml
      File.open("chess/minesweep_games/#{@file_name}", "w") {|file| file.write(serialized)}
    end
    
    puts "\nThanks for playing Minesweeper!"
  end
  
  def continue_old_game?
    new_old = ''
    while new_old.empty?
      puts "Would you like to start a new game or continue an old game? NEW  OLD"
      user_decision = gets.chomp.upcase
      if %w(NEW OLD N O).include? user_decision
        new_old = user_decision
      else
        puts "Please respond with NEW or OLD.".colorize(:light_red)
      end
    end
    
    new_old.split('').include?('O')
  end
  
  def load_old_game
    old_game = ''
    games = Dir.entries("minesweeper/minesweep_games")
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
    
    YAML::load_file("minesweeper/minesweep_games/#{old_game}").play(new = false)
    
    return true
    
  end
  
end

game = Minesweeper.new

# game.display_grid(true)

game.play