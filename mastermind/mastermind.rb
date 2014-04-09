class Mastermind
  
  PEGS = %w(R G B Y O P)
  # red, green, blue, yellow, orange, purple
  
  attr_reader :code, :guess
  
  def initialize
    @code = PEGS.sample(4)
    @guess = ""
  end
  
  def play
    loop do
      reset_guess
      user_guess until valid_guess || quit? 
      break if quit?
      parse_guess
      feedback
      break if won?
    end
    "Thanks for playing!"
  end
  
  private
  
  def reset_guess
    @guess = ""
  end
  
  def user_guess
    puts "Guess the code! Enter 4 color letters from #{PEGS.to_s}."
    @guess = gets.chomp
  end
  
  def valid_guess
    @guess.upcase.split('').select {|color| PEGS.include? color}.length == 4
  end
  
  def quit?
    @guess.downcase == 'quit'
  end
  
  def parse_guess
    @guess = @guess.upcase.scan(/\w/)
  end
  
  def feedback
    if @guess == @code
      puts "You won!"
    else
      n_exact_matches = exact_matches
      n_near_matches = near_matches
      puts "You have #{n_exact_matches} exact matches and #{n_near_matches} near matches."
    end
  end
  
  def exact_matches
    matches = 0
    @guess.each_index do |color|
      matches += 1 if @guess[color] == @code[color]
    end
    matches
  end
  
  def near_matches
    matches = 0
    @guess.each_index do |color|
      matches += 1 if @code.include?(@guess[color]) && @guess[color] != @code[color]
    end
    matches
  end
  
  def won?
    @guess == @code
  end
  
end

