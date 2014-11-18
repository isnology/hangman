# Simple Hangman game
#
# Goals:-
# to learn Ruby skills.
# implement duck-types.
# duck-types ordering to be of no consequence
# loosley coupled code.
# keep it simple to aid the above.
#
class DuckType
  attr_accessor :preparers, :players

  def initialize
    @preparers = []
    @players = []
  end
end

class Picture
  attr_reader :canvas

  def initialize
    @canvas = []
    @canvas << "      __________".split(//)
    @canvas << "      |       \\|".split(//)
    4.times { @canvas << "               |".split(//) }
    @canvas << "              /|".split(//)
    @canvas << " ____________/_|_".split(//)
    2.times { @canvas << "                 ".split(//) }
  end

  def put_to_console
    system('clear')
    @canvas.each { |array| puts array.join }
    puts
  end
end

class Man

  def initialize(canvas, duck)
    # ignore the zero element (start from position 1)
    @man_components = [' ', 'O', '|', '/', "\\", '|', '/', "\\"]
    @man_coordinates = [[2,5],[2,6],[3,6],[3,5],[3,7],[4,6],[5,5],[5,7]]
    @canvas = canvas
    duck.preparers << self
    duck.players << self
  end

  def new_game
    @incorrect_guesses = 0
    @man_coordinates.each_index { |x| plot(@man_coordinates[x], ' ') }
  end

  def draw
    plot(@man_coordinates[@incorrect_guesses], @man_components[@incorrect_guesses] )
  end

  def incorrect_guess
    @incorrect_guesses += 1
  end

  def complete?
    @incorrect_guesses >= @man_components.size - 1
  end

  private

    def plot(coordinates, char)
      @canvas[ coordinates[0] ][ coordinates[1] ] = char
    end
end

class Word
  attr_reader :target_word

  def initialize(canvas, duck)
    @words = []
    File.foreach("hangman.txt") { |line| @words << line.chomp.split(',') }
    srand
    @canvas = canvas
    duck.preparers << self
    duck.players << self
  end

  def draw
    @target_result.each_index { |x| @canvas.last[x + 1] = @target_result[x] }
  end

  def new_game
    @target_result.each_index { |x| @canvas.last[x + 1] = ' ' } if @target_result
    x = rand(@words.size)
    @target_word = @words[x][0]
    @hint = @words[x][1]
    @target_result = []
    @target_word.each_char { @target_result << '_' }
  end

  def guess
    puts "Hint:- #{@hint}\n\n"
    print 'enter a letter:'
    char = gets.strip.downcase
    increment = nil
    @target_result.each_index do |x|
      increment = @target_result[x] = char if @target_word.slice(x) == char
    end
    increment
  end

  def complete?
    !@target_result.include?('_')
  end
end

#- main -------------------------------------------------------------
duck = DuckType.new
picture = Picture.new
man = Man.new(picture.canvas, duck)
word = Word.new(picture.canvas, duck)

win = "Congratulations, you got it."
lose = "Sorry, you lose. The word was: "

begin
  duck.preparers.each { |prepare| prepare.new_game }

  loop do
    duck.players.each { |play| play.draw }
    picture.put_to_console
    break if man.complete? || word.complete?
    man.incorrect_guess unless word.guess
  end

  puts word.complete? ? win : lose + word.target_word

  print "\nAnother game (y/n)"
end while gets.strip.upcase == 'Y'