require 'debugger'
class Hangman

  def initialize(humans)
    @players = get_players(humans)
    @word = @players[0].choose_word.split("")
    @guesses = []
  end

  def get_players(humans)
    raise "Invalid Players" unless humans.between?(0,2)

    case humans
    when 0 then [ComputerPlayer.new, ComputerPlayer.new]

    when 1 then
      begin
        puts "Are you the guesser? (Y/n)"
        input = gets.chomp.downcase
        unless %w(n y).include?(input)
          raise StandardError.new "Please enter 'y' or 'n' and suck less."
        end
      rescue StandardError => e
        puts e.message
        retry
      end

      if input == 'y'
        [ComputerPlayer.new, HumanPlayer.new]
      else
        [HumanPlayer.new, ComputerPlayer.new]
      end

    else [HumanPlayer.new, HumanPlayer.new]
    end
  end

  def play
    until end?
      display
      input
    end

    display

    puts win? ? "Nice." : "Womp."
  end

  def display
    puts "You have #{guesses_left} guesses left!"

    @word.each do |chr|
      printf @guesses.include?(chr) ? "#{chr} " : "_ "
    end

    puts ""
    @guesses.length != 0 ? p(@guesses) : puts("")
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  end

  def input
    @guesses << @players[1].guess(@guesses, @word)
  end

  def end?
    win? || guesses_left == 0
  end

  def win?
    @word.all? { |chr| @guesses.include?(chr) }
  end

  def guesses_left
    10 - @guesses.inject(0){ |sum,chr| @word.include?(chr) ? sum : sum+1}
  end

end

class Player
  DICTIONARY = File.foreach('dictionary.txt').map { |line| line.chomp}
end

class HumanPlayer < Player
  def choose_word
    puts "Choose wisely, your chosen word."
    input = gets.chomp.downcase

    unless DICTIONARY.include?(input)
      raise StandardError.new "That's not a word! AGAIN!!!"
    end

    input

  rescue StandardError => e
    puts e.message
    retry
  end

  def guess(guesses, word)
    puts "Choose a letter - choose wisely."
    input = gets.chomp.downcase

    unless (("a".."z").to_a - guesses).include?(input)
      raise StandardError.new "That's not a word! AGAIN!!!"
    end

    input

  rescue StandardError => e
    puts e.message
    retry
  end
end

class ComputerPlayer < Player

  def initialize
    @letter_frequency = get_frequency
  end

  def get_frequency
    frequency = Hash.new 0
    DICTIONARY.each do |word|
      word.split("").each do |chr|
        frequency[chr] += 1
      end
    end
    frequency.sort_by { |k,v| v }.reverse
  end

  def choose_word
    DICTIONARY.sample
  end

  def guess(guesses, solution)
    #find words of the same length
    @possible_words ||= DICTIONARY.select { |wrd| wrd.length == solution.length }

    #find index of guessed letters
    matched_i = []
    solution.each_with_index do |chr, i|
      matched_i << i if guesses.include?(chr)
    end

    unmatched_i = []
    solution.each_with_index do |chr, i|
      unmatched_i << i unless guesses.include?(chr)
    end

    #eliminate impossible words

    matched_i.each do |i|
      @possible_words.delete_if do |wrd|
        wrd[i] != solution[i]
      end
    end

    choices = ("a".."z").to_a - guesses
    choice_frequency = Hash.new 0

    @possible_words.each do |wrd|
      wrd.split("").each_with_index do |chr,i|
        if unmatched_i.include?(i) && choices.include?(chr)
          choice_frequency[chr] += 1
        end
      end
    end

    max_frequency = choice_frequency.values.max
    max_frequency_keys = choice_frequency.select { |k,v| v == max_frequency }.keys

    @letter_frequency.each do |array|
      if max_frequency_keys.include?(array[0])
        return array[0]
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  h = Hangman.new(1)
  h.play
end