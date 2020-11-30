class TicTacToe

  def initialize
    default_settings()
    start_menu()
  end

  def start_menu
    puts "Welcome to TicTacToe!"
    puts "Options:\n1. Start\n2. How to Play"
    input = get_input()

    if input == "1"
      choose_mode()
    elsif input == "2"
      rules()
    else
      puts "Please enter a valid option\n"
      start_menu()
    end   
  end

  def rules
    puts "EXAMPLE BOARD: "
    puts "\nHow to play:\nSelect a square on the tic-tac-toe board"\
        "by inputting the appropriate code. (The codes are NOT case sensitive)."

    example_board = %Q(
      ___ ___ ___
     | a1| a2| a3|
     ---- ---- ---
     | b1| b2| b3|
     ---- ---- ---
     | c1| c2| c3|
     ---- ---- --- 

    )
    puts example_board
    puts "Start? (y/n)"
    input = get_input()
    if input == "y" then choose_mode() else nil end
  end

  def default_settings
    @board = [["-","-","-"],["-","-","-"],["-","-","-"]]
    @rounds = 1
  end

  def choose_mode
    puts "\nOptions:\n1. Player vs Player\n2. Player vs AI"
    input = get_input()
    if input == "2"
      PvAI_settings()
      startRound()
    elsif input == "1"
      PvP_settings()
      startRound()
    else
      puts "Please enter a valid option!"
      choose_mode()
    end   
  end

  def PvAI_settings
    @AI_playing = true
    @human = "X"
    @ai = "O"
    @scores = {"X"=>1, "O"=>-1, "tie"=> 0}
  end

  def PvP_settings
    @AI_playing = false
    @P1 = "X"
    @P2 = "O"
  end
    
  def draw_board
    board = []
    (0..2).each do |i|
      board << @board[i].join(" ")
    end
    puts board
  end

  def get_input
    input = gets.chomp
    return input
  end

  def startRound()
    puts "\nRound: #{@rounds}"
    draw_board()

    #Check if AI's turn (if AI is playing)
    if @rounds % 2 == 0 && @AI_playing
      AI_move()

    #Start Human turns (P1 or P2)
    else 
      inp = get_input()

      #Setting up the correct player piece "X" or "O"
      if @rounds % 2 != 0 then mark = "X" else mark = "O" end
      
      #Checking to see if the input is a valid code. 
      if valid_input?(inp) 
        board_indexes = convert_input_code(inp)
        i = board_indexes[0]
        j = board_indexes[1]

        #If spot on board not occupied, add it there
        if @board[i][j] == "-" 
          @board[i][j] = mark
          @rounds += 1
        else
          puts "Spot already taken!"
        end
      else
        puts "Invalid Input!"
      end
      #Check state of the game (win/loss/draw).
      game_state?()
    end
  end

  def valid_input?(inp)
    @all_valid = ["a1", "b1", "c1", "a2", "b2", "c2", "a3", "b3", "c3"]
    if @all_valid.include?(inp.downcase) then return true else return false end
  end

  def game_state?()
    if win?("X")
      puts "\n"
      draw_board()
      puts "Winner! X"
      end_of_game()

    elsif win?("O")
      puts "\n"
      draw_board()
      puts "Winner! O"
      end_of_game()

    elsif tie?()
      puts "\n"
      draw_board()
      puts "Its a tie."
      end_of_game()
    else
      #If no terminal state, start a new round. 
      startRound() 
    end
  end

  def eval_game_state()
    if win?("X") #win
      return "X"
    elsif win?("O") #loss
      return "O"
    elsif tie?()
      return "tie"
    else
      return nil
    end
  end

  def win?(mark)
    #evaluate row win
    @board.each do |row|
      if row.all?{|item| item == mark}
        return true
      end
    end
    #evalute column win
    (0..2).each do |i|
      if @board.all?{|item| item[i] == mark}
        return true
      end
    end
    #evaluate diagonal win
    if @board[0][0] == mark && @board[1][1] == mark && @board[2][2] == mark
      return true
    elsif @board[0][2] == mark && @board[1][1] == mark && @board[2][0] == mark
      return true
    end
    #If none of the above win conditions are met, return false
    return false
  end

  def tie?
    full_row = 0
    @board.each do |row|
      if row.all?{|item| item == "X" || item == "O"}
        full_row += 1
      end
    end
    return full_row == 3
  end

  def end_of_game()
    puts "Would you like to play again? (y/n)"
    input = get_input()
    if input == "y"
      default_settings()
      startRound()
    end
  end

  #Convert input code to indexes of the board (ex.a2 to [0,1])
  def convert_input_code(code)
    indexes = []
    code = code.downcase.split("")
    if code[0] == "a"
      indexes << 0
    elsif code[0] == "b"
      indexes << 1
    elsif code[0] == "c"
      indexes << 2
    end
    indexes << (code[1].to_i)-1
    return indexes
  end

  # AI IMPLEMENTATION

  # Utilizies the minimax algorithim so the AI player can make the optimal choice in Tic-Tac-Toe
  # X is maximixing (human), O is minimizing (AI), hence AI wants to compute the LOWEST score possible.

  def minimax(board, depth, isMaximixing)
    result = eval_game_state()

    #Grab the respective score determined by the final state of game (win, lose, draw), if applicable.
    if result != nil 
      score = @scores[result]
      return score
    end

    #Human Player's Turn
    if isMaximixing 
      bestScore = 99999999999999999999999999999999999999999999999999
      (0..2).each do |i|
        (0..2).each do |j|
          if @board[i][j] == "-"
            @board[i][j] = @human
            score = minimax(@board, depth+1, false)
            @board[i][j] = "-"
            if score < bestScore 
              bestScore = score
            end
          end
        end
      end
      return bestScore

    #AI player's turn
    else 
      bestScore = -99999999999999999999999999999999999999999999999999
      (0..2).each do |i|
        (0..2).each do |j|
          if @board[i][j] == "-"
            @board[i][j] = @ai
            score = minimax(@board, depth+1, true)
            @board[i][j] = "-"
            if score > bestScore 
              bestScore = score
            end
          end
        end
      end
      return bestScore
    end
  end

  def AI_move
    bestscore = 99999999999999999999999999999999999999999999999999
    move = []

    #Iterate thru board, going through all possible options, finding the LOWEST score possible as the minimzer (AI).
    (0..2).each do |i|
      (0..2).each do |j|
        if @board[i][j] == "-" 
          @board[i][j] = @ai
          score = minimax(@board, 0, true)
          @board[i][j] = "-"

          if score < bestscore
            bestscore = score
            move = [i, j]
          end
        end
      end
    end
    
    #Once the optimal move is found, add it to the board and start a new round. 
    @board[move[0]][move[1]] = @ai
    @rounds += 1
    game_state?()
  end

end

game = TicTacToe.new()

