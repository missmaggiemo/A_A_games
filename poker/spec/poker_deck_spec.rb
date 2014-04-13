require 'rspec'
require 'poker_deck'

describe PokerDeck do

  subject(:deck) { PokerDeck.new }

  describe '#cards' do

    it 'returns an array of all cards in the deck' do
      expect(deck.cards).to eq(PokerDeck.all_cards)
    end

  end

  describe '#take' do

    let(:card_array) do
      card_array = [
      PokerCard.new(:spades, :queen),
      PokerCard.new(:hearts, :ace),
      PokerCard.new(:clubs, :ten)
    ]
    end

    let(:deck2) {PokerDeck.new(card_array.dup)}

    it "removes 'n' cards from the deck" do
      deck2.take(2)
      expect(deck2.cards).to eq(card_array[-1,1])
    end

    it "returns the removed cards" do
      expect(deck2.take(2)).to eq(card_array[0..1])
    end
  end

  describe '#return' do
    let(:card_array) do
      card_array = [
      PokerCard.new(:spades, :queen),
      PokerCard.new(:hearts, :ace),
      PokerCard.new(:clubs, :ten)
    ]
    end

    let(:deck2) {PokerDeck.new(card_array.dup)}

    it "returns 'n' cards to the deck" do
      first_card = deck2.take(1)
      new_array = card_array[1,2] + first_card
      expect(deck2.return(first_card)).to eq(new_array)
    end
  end

end


