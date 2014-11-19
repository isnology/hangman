# Simple Hangman game (top 100 words) or change the file hangman.txt to what you want
#
# Goals:-
# to learn Ruby skills.
# implement duck-types.
# duck-types ordering to be of no consequence
# loosley coupled code.
# keep it simple to aid the above.
#
PICTURE_SIZE = 17

class DuckType
  attr_accessor :new_game, :draw

  def initialize
    @new_game = []
    @draw = []
  end
end

class Picture
  attr_reader :canvas

  def initialize
    @canvas = []
    @canvas << "      __________"
    @canvas << "      |       \\|"
    4.times { @canvas << "               |" }
    @canvas << "              /|"
    @canvas << " ____________/_|_"
    2.times { @canvas << " " * PICTURE_SIZE }
  end

  def put_to_console
    system('clear')
    puts @canvas
    puts
  end
end

class Man

  def initialize(canvas, duck)
    # ignore the zero element (start from position 1)
    @man_components = [' ', 'O', '|', '/', "\\", '|', '/', "\\"]
    @man_coordinates = [[2,5],[2,6],[3,6],[3,5],[3,7],[4,6],[5,5],[5,7]]
    @canvas = canvas
    duck.new_game << self
    duck.draw << self
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
    duck.new_game << self
    duck.draw << self
  end

  def draw
    @canvas.last[1,@target_result.size] = @target_result
  end

  def new_game
    @canvas.last[0,17] = " " * PICTURE_SIZE
    x = rand(@words.size)
    @target_word, @hint = @words[x]
    @target_result = '_' * @target_word.size
  end

  def guess
    puts "Hint:- #{@hint}\n\n"
    print 'enter a letter:'
    char = gets.strip.downcase
    increment = nil
    0.upto(@target_word.size - 1) do |x|
      increment = @target_result[x] = char if @target_word[x] == char
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
  duck.new_game.each { |prepare| prepare.new_game }

  loop do
    duck.draw.each { |game_part| game_part.draw }
    picture.put_to_console
    break if man.complete? || word.complete?
    man.incorrect_guess unless word.guess
  end

  puts word.complete? ? win : lose + word.target_word

  print "\nAnother game (y/n)"
end while gets.strip.upcase == 'Y'