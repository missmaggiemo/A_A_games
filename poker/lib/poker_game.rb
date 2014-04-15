load 'poker/lib/poker_hand.rb'
load 'poker/lib/poker_player.rb'
load 'poker/lib/poker_deck.rb'
require 'colorize'

class PokerGame
  
  attr_accessor :players, :bets
  
  ANTE = 200
  
  BANKROLL = ANTE * 100
  
  def initialize
    @players = []
    @current_players = []
    @current_bet = 0
    @current_winner = nil
    @turn_counter = 0
    @bets = Hash.new(0)
    @deck = PokerDeck.new
  end
  
  def play
    system('clear')
    puts "Welcome to Console Poker!"
    n_players = num_players  
    n_players.times {|n| @players << add_player(n)}
    system('clear')
    puts "All players begin with a bankroll of $#{BANKROLL}. The ante for each game is $#{ANTE}."
    
    loop do
      begin
        system('clear')
        break if ante_up == 'quit'
        deal_hands
        exchange_cards
        loop do
          @current_players.each do |player| 
            next if betting_over?
            turn(player)
          end
          break if betting_over?
        end
      rescue => e
        puts e
        sleep(1)
        retry
      end
      show_hands
      best_hand
      pay_bets
      list_bankrolls
      remove_insolvent_players
      break if game_over?
      break if next_hand_prompt == 'quit'
      reset_ivars_for_new_hand
    end
    
    "Thanks for playing poker!"
    
  end
  
  
  
  # game setup
  
  def num_players
    n_players = nil
    until n_players
      puts "How many players?"
      user_n_players = gets.chomp.to_i
      if user_n_players >= 2 && user_n_players <= 6
        n_players = user_n_players
      elsif user_n_players < 2
        puts "Number of players must be at least 2.".colorize(:red)
      elsif user_n_players > 6
        puts "Number of players must not exceed 6.".colorize(:red)
      end
    end
    n_players
  end
  
  def add_player(n)
    system('clear')
    player = nil
    until player
      puts "Player #{n+1}, what is your name?"
      name = gets.chomp.capitalize
      if name.length > 0
        player = PokerPlayer.new(name, BANKROLL)
      else
        puts "You must enter a name.".colorize(:red)
      end
    end
    player
  end
  
  # methods for each hand
  
  def ante_up
    @players.each do |player|
      system('clear')
      puts "#{player}, your bankroll is $#{player.bankroll}"
      puts "Are you playing this round? Ante is $#{ANTE}. Y / N"
      if gets.chomp.upcase.include?('Y')
        take_bet(player, ANTE)
        @current_players << player
      else
        leave_table?(player)
        return 'quit' if game_over?
      end
      sleep(1)
    end
    @turn_counter = @current_players.length
    if @turn_counter < 2
      repay_ante
      raise "There must be at least 2 players per hand.".colorize(:red)
    end
  end
  
  def repay_ante
    @bets.each do |player, bet|
      player.bankroll += bet
    end
    @bets = Hash.new(0)
  end
  
  def leave_table?(player)
    puts "Would you like to leave the game? Y / N"
    if gets.chomp.upcase.include?('Y')
      puts "Goodbye, #{player}!"
      remove_player(player)
      sleep(1)
    else
      puts "Okay, we'll skip you for this round.".colorize(:red)
    end
  end
  
  def take_bet(player, amt)
    begin
      @bets[player] += player.place_bet(amt)
    rescue => e
      puts e
      retry
    end
    puts "Bet placed: $#{amt}"
  end
  
  def deal_hands
    @deck.shuffle
    @current_players.each do |player|
      player.hand = PokerHand.new(cards = @deck.take(5), deck = @deck)
      player.hand.sort!
    end
  end
  
  def exchange_cards
    @current_players.each do |player|
      system('clear')
      puts "#{player}, this is your hand:"
      player.print_hand
      puts "#{player}, would you like to discard any cards? Y / N"
      if gets.chomp.upcase.split('').include?('Y')
        discarded = player.choose_cards_to_discard
        player.hand.discard(discarded)
        player.hand.add_cards(@deck.take(discarded.length))
        player.hand.sort!
        puts "#{player}, this is your new hand:"
        player.print_hand
        puts "Press [return] to continue."
        next if gets
      end
    end
  end
  
  # betting
  
  def turn(player)
    system('clear')
    player_action = player.get_action
    
    case player_action
    when "FOLD", "F"
      player.fold
      @current_players.delete(player)
      player.hand = nil
      @turn_counter -= 1
    when "STAY", "S"
      take_bet(player, @current_bet)
      @turn_counter -= 1
    when "RAISE", "R"
      poker_raise(player)
    end
    sleep(1)
  end
  
  def poker_raise(player)
    user_bet = 0
    first_bet = @current_bet
    until user_bet > first_bet
      puts "Your bankroll is $#{player.bankroll}."
      puts "The current bet is $#{@current_bet}. To RAISE, you must bet more. How much do you want to bet?"
      user_bet = gets.chomp.scan(/\d+/).first.to_i
      if user_bet > first_bet
        take_bet(player, user_bet)
        @current_bet = user_bet
        reset_turn_counter
      else
        puts "You must bet more than the current bet, $#{@current_bet}".colorize(:red)
      end
    end
  end
  
  def reset_turn_counter
    
    # keeps track of how many people need to respond to a particular bet-- betting is over when everyone has responded to the most recent bet, and no one has raised
    
    @turn_counter = @current_players.length
  end
  
  def betting_over?
    @turn_counter < 1 || @current_players.length < 2
  end
  
  # after betting

  def show_hands
    system('clear')
    @current_players.each do |player|
      puts "#{player}: #{player.hand}"
    end
  end
  
  def best_hand
    best = nil
    @current_players.each do |player|
      if best.nil? || player.hand > best.hand
        best = player
      elsif  best.hand == player.hand
        best = handle_ties(best, player)
      end
    end
    puts "Best hand: #{best.hand}"
    @current_winner = best
  end
  
  def handle_ties(best, player)
    case best.hand.find_poker_subsets
    when 0, 4, 5, 8
      handle_high_card_tie(best, player)
    when 1
      handle_pair_tie(best, player)
    when 2
      handle_two_pair_tie(best, player)
    when 3, 6
      handle_triple_tie(best, player)
    when 7
      handle_quad_tie(best, player)
    end
  end
  
  def handle_high_card_tie(best, player)
    # returns original best player unless the other player has a higher card
    (best.hand.length - 1).downto(0) do |card_i|
      next if best.hand[card_i].poker_value == player.hand[card_i].poker_value
      if best.hand[card_i] > player.hand[card_i]
        return best
      else
        return player
      end
    end
  end
  
  def handle_pair_tie(best, player)
    if best.hand.find_pair_card.poker_value == player.hand.find_pair_card.poker_value
      return handle_high_card_tie(best, player)
    else
      best.hand.find_pair_card > player.hand.find_pair_card ? best : player
    end
  end
  
  def handle_two_pair_tie(best, player)
    if best.hand.find_two_pair_cards.sort == player.hand.find_two_pair_cards.sort
      return handle_high_card_tie(best, player)
    else
      (0..3).each do |i|
        if best.hand.find_two_pair_cards[i] > player.hand.find_two_pair_cards[i]
          return best
        else
          return player
        end
      end
    end
  end
  
  def handle_triple_tie(best, player)
    best.hand.find_triple_card > player.hand.find_triple_card ? best : player
  end
  
  def handle_quad_tie(best, player)
    best.hand.find_quad_card > player.hand.find_quad_card ? best : player
  end
  
  def pay_bets
    @current_winner.pay_winnings(@bets.values.inject(:+))
  end
  
  def list_bankrolls
    @current_players.each do |player|
      puts "#{player}: $#{player.bankroll}"
    end
  end
  
  def remove_insolvent_players
    @players.each do |player|
      if player.lost?(ANTE)
        remove_player(player)
        puts "Sorry #{player}, you're out of the game!".colorize(:red)
      end
    end
  end
  
  def remove_player(player)
    @players.delete(player)
  end
  
  def next_hand_prompt
    puts "Press [return] to deal the next hand, or type 'QUIT' to end the game."
    if gets.chomp.upcase.split('').include?('Q')
      return 'quit'
    end
  end
  
  def reset_ivars_for_new_hand
    @current_players.each do |player|
      player.return_cards
    end
    @current_players = []
    @bets = Hash.new(0)
    @current_winner = nil
    @current_bet = 0
    @turn_counter = 0
  end
  
  # game over?
  
  def game_over?
    
    # the game is over when there's only one player left at the table
    
    if @players.length == 1
      puts "#{players.last}, you won! You're the only player left at the table."
      true
    else
      false
    end
  end

  
end


PokerGame.new.play