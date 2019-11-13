class Game
  def initialize(board, players)
    @board = board
    @players = players
  end

  def play
    loop do
      @players.each do |player|
        dice_value = throw_dice
        print "Player: #{player.id} Dice value: #{dice_value}\n"
        @board.move(dice_value, player)

        break if @board.last_cell_occupied?
        sleep(0.25)
      end

      @board.display

      if @board.last_cell_occupied?
        print "******************************"
        print "Player  #{@board.player_at_last_cell} won"
        print "******************************"
        break
      end
    end
  end

  private

  def throw_dice
    (1..6).to_a.sample
  end
end

class Player
  attr_reader :id
  attr_reader :current_index

  def initialize(id, money_in_hand = 1000)
    @id = id
    @current_index = 0
    @money_in_hand = money_in_hand
  end

  def update_position(index)
    @current_index = index
  end
end

class Board
  def initialize(pattern)
    @board = create_board(pattern)
  end

  def move(dice_value, player)
    @board[player.current_index].move_out(player)

    next_position = if (player.current_index + dice_value) > max_index
      max_index
    else
      player.current_index + dice_value
    end

    @board[next_position].occupy(player)
    player.update_position(next_position)
  end

  def last_cell_occupied?
    @board.last.occupied?
  end

  def display
    print @board.map(&:status).join(" ")
    print "\n"
  end

  def player_at_last_cell
    @board.last.occupied_player_ids
  end

  private

  def max_index
    @board.length - 1
  end

  def create_board(pattern)
    pattern.downcase.split('').map do |char|
      cell_type(char).new
    end
  end

  def cell_type(char)
    {
      'c' => Cell
    }[char]
  end
end

class Cell
  def initialize
    @occupied_by = []
  end

  def occupy(player)
    @occupied_by << player
  end

  def move_out(player)
    @occupied_by.delete(player)
  end

  def occupied?
    !@occupied_by.empty?
  end

  def status
    @occupied_by.map(&:id).inspect
  end

  def occupied_player_ids
    "#{@occupied_by.map(&:id).join(', ')}"
  end
end

board = Board.new("ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc")
players = [1, 2, 3].map {|id| Player.new(id) }

Game.new(board, players).play
