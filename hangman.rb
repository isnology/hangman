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

  def new_game
  end

  def draw
    system('clear')
    @canvas.each { |array| puts array.join }
    puts
  end
end

class Man

  def initialize(canvas)
    # ignore the zero element (start from position 1)
    @master_man = [' ', 'O', '|', '/', "\\", '|', '/', "\\"]
    @map = [[2,5],[2,6],[3,6],[3,5],[3,7],[4,6],[5,5],[5,7]]
    @canvas = canvas
  end

  def new_game
    @incorrect_guesses = 0
    @map.each_index { |step| plot(step, ' ') }
  end

  def draw
    plot(@incorrect_guesses, @master_man[@incorrect_guesses] )
  end

  def incorrect_guess
    @incorrect_guesses += 1
  end

  def complete?
    @incorrect_guesses >= @master_man.size - 1
  end

  private

    def plot(step, char)
      @canvas[ @map[step][0] ][ @map[step][1] ] = char
    end
end

class Word
  attr_reader :target_word

  def initialize(canvas)
    @words = %w[sleep cat frog running elephant car rat piano horse house dog desk mouse mouth
                truck rock flip bike mike sew there their here was up down because when with]
    Random.new_seed
    @canvas = canvas
  end

  def draw
    @target_result.each_index { |x| @canvas.last[x + 1] = @target_result[x] }
  end

  def new_game
    @target_result.each_index { |x| @canvas.last[x + 1] = ' ' } if @target_result
    @target_word = @words[rand(@words.size)]
    @target_result = []
    @target_word.each_char { @target_result << '_' }
  end

  def guess
    print 'enter a letter:'
    char = gets.slice(0).downcase
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
picture = Picture.new
component = []
component << man = Man.new(picture.canvas)
component << word = Word.new(picture.canvas)
component << picture      # picture must be last in array
win = "Congratulations, you got it."
lose = "Sorry, you lose. The word was: "

begin
  component.each { |prepare| prepare.new_game }

  loop do
    component.each { |play| play.draw }
    break if man.complete? || word.complete?
    man.incorrect_guess unless word.guess
  end

  puts word.complete? ? win : lose + word.target_word

  print "\nAnother game (y/n)"
end while gets.slice(0).upcase == 'Y'