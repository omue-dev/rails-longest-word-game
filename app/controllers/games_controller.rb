require "open-uri"
require "json"

class GamesController < ApplicationController
  def new
    @letters = []
    @letters += Array.new(10) { ('A'..'Z').to_a.sample }
    @letters.shuffle!
    session[:score] ||= 0   # initialize score if not set yet
  end

def score
  @word = params[:word].upcase
  @letters = params[:letters].chars

  if !can_be_built?(@word, @letters)
    @result = "Sorry but #{@word} can't be built out of #{@letters.join(', ')}"
  elsif !english_word?(@word)
    @result = "Sorry but #{@word} does not seem to be a valid English word..."
  else
    @result = "Congratulations! #{@word} is a valid English word!"
    session[:score] ||= 0
    session[:score] += @word.length
  end

  # Always keep track of the grand total
  @grand_total = session[:score] || 0
end



  private

  def can_be_built?(word, letters)
    # Transform the word into an array of characters (.chars).
    # For every character in the word check:
    # "Do I have at least this many of that character available in the letters array?"
    # If that's true for all characters (.all?) -> return true
    # If it's false for at least one character -> return false
    word.chars.all? do |char|
      #   word = "TEST", char = "T"   -> word.count("T") = 2
      #   letters = ["T","E","S","T"] -> letters.count("T") = 2
      #   2 <= 2  -> true
      word.count(char) <= letters.count(char)
    end
  end

  def english_word?(word)
    url = "https://dictionary.lewagon.com/#{word.downcase}"
    response = URI.open(url).read
    data = JSON.parse(response)
    data["found"]
  end
end
