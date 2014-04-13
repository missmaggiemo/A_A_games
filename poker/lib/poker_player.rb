require 'colorize'

class PokerPlayer
  
  attr_reader :name
  attr_accessor :hand, :bankroll

  def initialize(name, bankroll)
    @name = name
    @bankroll = bankroll
    @hand = nil
  end
  
  def to_s
    @name
  end
  
  
  def get_action
    print_hand
    action = nil
    until action
      puts "What would you like to do?  FOLD  STAY  RAISE"
      user_action = gets.chomp.upcase
      if user_action.empty?
        action = 'STAY'
      elsif %w[FOLD STAY RAISE F S R].include?(user_action)
        action = user_action
      else
        puts "#{user_action} is an invalid action.".colorize(:red)
      end
    end
    action
  end
  
  

  def pay_winnings(bet_amt)
    @bankroll += bet_amt
    puts "#{@name}, you added $#{bet_amt} to your bankroll."
  end

  def return_cards
    self.hand.return_cards
    @hand = nil
  end

  def place_bet(bet_amt)
    raise "You can't cover that bet. Your bankroll is only $#{@bankroll}.".colorize(:red) if @bankroll < bet_amt
    @bankroll -= bet_amt
    bet_amt
  end
  
  def fold
    return_cards(deck)
  end
  
  def lost?(ante)
    @bankroll < ante
  end
  
  def print_hand
    puts @hand.sort.map {|card| card.to_s}.join('  ')
  end
  
  def print_hand_with_indices
    puts @hand.sort.map.with_index {|card, i| "#{i + 1}: ".colorize(:light_yellow) + card.to_s}.join(',  ')
  end
  
  def choose_cards_to_discard
    discard_cards = []
    while discard_cards.empty?
      puts "Please list the " + 'numbers'.colorize(:light_yellow) + " corresponding to the cards that would you like to discard."
      print_hand_with_indices
      user_discard_cards = gets.chomp.scan(/\d/).map {|n| n.to_i - 1}
      if user_discard_cards.any? {|n| n < 0 || n > 4}
        puts "Invalid card number.".colorize(:red)
      else
        discard_cards = user_discard_cards
      end
    end
    discard_cards
  end
  
end