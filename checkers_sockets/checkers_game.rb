load 'checkers_sockets/checkers_board.rb'
require 'date'
require 'yaml'
require 'socket'

$hostname = 'localhost'
$port = 8080

class CheckersGame
  
  attr_accessor :black, :red, :board, :filename
  
  def initialize
    @board = CheckersBoard.new
  end
  
  
  def play(mode)
    @mode = mode # :server, :client
    @socket = get_socket(mode)
    
    system('clear')
    
    STDOUT.puts(@mode.to_s)
    
    @color = :black
    
    loop do
      begin
        break if turn == :quit
        break if game_over?
      rescue => e
        puts e
        sleep(1)
        retry
      end
      sleep(1)
      @color == :black ? @color = :red : @color = :black
    end
    
    puts "Thanks for playing Checkers!"
  end
  
  
  
  
  
  def turn
    system('clear')
    STDOUT.puts(@mode.to_s.upcase)
    self.board.display_board
    
    if (@mode == :server) == (@color == :black)
      STDOUT.puts "Your turn!"
      
      start_pos = get_start_pos
    
      return :quit if start_pos == :quit
      raise "There's no piece there!" if self.board[start_pos].nil?
      raise "That's not your piece!" if self.board[start_pos].color != @color
    
      end_pos = get_end_pos
      return :quit if end_pos == :quit
      move_sequence = self.board.parse_moves(start_pos, end_pos)
      
      @socket.puts(move_sequence.to_s)
    else
      move_sequence = eval(@socket.gets.chomp)
    end
    
    self.board.perform_moves(move_sequence)
    
  end
  
  
  
  
  def game_over?
    [:red, :black].any? do |color|
      @board.board_mat.flatten.none? {|piece| !piece.nil? && piece.color == color}
    end
  end
  
    
  
  def get_socket(mode)
    if mode == :server
      server = TCPServer.open($port)
      socket = server.accept
    else
      begin
        socket = TCPSocket.open($hostname, $port)
      rescue => error
        retry
      end
    end
    socket
  end
  
  
  
  def get_start_pos
    pos = []
    while pos.empty?
      puts "#{@color.to_s.capitalize}, which piece do you want to move?"
      user_pos = STDIN.gets.chomp
      return :quit if user_pos.downcase.match(/q/)
      if user_pos.scan(/\d/)[0,2].length == 2
        pos = user_pos.scan(/\d/)[0,2].map{|n| n.to_i - 1}
      else
        puts "Position not valid."
      end
    end
    pos
  end
  
  
  def get_end_pos
    pos = []
    while pos.empty?
      puts "Where do you want to put it?"
      user_pos = STDIN.gets.chomp
      return :quit if user_pos.downcase.match(/q/)
      if user_pos.scan(/\d/)[0,2].length == 2
        pos = user_pos.scan(/\d/)[0,2].map{|n| n.to_i - 1}
      else
        puts "Position not valid."
      end
    end
    pos
  end
  
end




game = CheckersGame.new

game.play(ARGV[0].to_sym)


