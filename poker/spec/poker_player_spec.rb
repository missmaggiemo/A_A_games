require 'poker_player'
require 'rspec'

describe PokerPlayer do
  
  subject(:player) {PokerPlayer.new('player', 20_000)}
  
  its(:name) {should eq 'player'}
  
  its(:bankroll) {should eq 20_000}
  
  describe '#hand' do 
    it 'should set a new hand' do
      player.hand = PokerHand.new([PokerCard.new(:hearts, :ace),
                                   PokerCard.new(:clubs, :ace),
                                   PokerCard.new(:hearts, :king),
                                   PokerCard.new(:diamonds, :king),
                                   PokerCard.new(:diamonds, :ace)
                                 ])
      expect(player.hand.cards).to eq([PokerCard.new(:hearts, :ace),
                                       PokerCard.new(:clubs, :ace),
                                       PokerCard.new(:hearts, :king),
                                       PokerCard.new(:diamonds, :king),
                                       PokerCard.new(:diamonds, :ace)
                                     ])                           
    end
  end
  
  describe '#pay_winnings' do
    it 'adds an amount to the bankroll' do
      player.pay_winnings(200)
      expect(player.bankroll).to eq(20200)
    end
  end
  
  describe '#return_cards' do
    
    it 'sets player\'s hand to nil' do
      player.hand = PokerHand.new([PokerCard.new(:hearts, :ace),
                                   PokerCard.new(:clubs, :ace),
                                   PokerCard.new(:hearts, :king),
                                   PokerCard.new(:diamonds, :king),
                                   PokerCard.new(:diamonds, :ace)
                                 ], PokerDeck.new)
      player.return_cards
      expect(player.hand).to eq(nil)
    end
  end
  
  
  
  
end