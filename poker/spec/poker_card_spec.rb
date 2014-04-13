require 'rspec'
require 'poker_card'

describe PokerCard do

  describe "attributes" do

    subject(:card) {PokerCard.new(:hearts, :queen)}
    
    its(:suit) {should eq :hearts}

    its(:value) {should eq :queen}
    
    its(:poker_value) {should eq 12}

  end

  describe "#==" do
    let(:card1) {PokerCard.new(:hearts, :queen)}
    let(:card2) {PokerCard.new(:hearts, :king)}
    let(:card3) {PokerCard.new(:spades, :queen)}

    it "non-same (e.g., queen of hearts and king of spades) cards are not equal" do
      expect(card1 == card2).to be_false
    end

    it "same-value (e.g., queen of hearts and queen of spades) cards are equal" do
      expect(card1 == card3).to be_true
    end

  end

  describe "#>" do
    let(:card1) {PokerCard.new(:hearts, :queen)}
    let(:card2) {PokerCard.new(:hearts, :king)}

    it "higher card is evaluated as > lower card" do
      expect(card2 > card1).to be_true
      expect(card1 > card2).to be_false
    end

  end

  describe "#<" do
    let(:card1) {PokerCard.new(:hearts, :queen)}
    let(:card2) {PokerCard.new(:hearts, :king)}

    it "lower card is evaluated as < higher card" do
      expect(card1 < card2).to be_true
      expect(card2 < card1).to be_false
    end

  end

end