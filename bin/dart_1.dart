import 'dart:io';
import 'dart:math';

class TicTacToe {
  late List<List<String>> board;
  late int size;
  String currentPlayer = 'X';
  bool isGameOver = false;
  String? winner;
  bool isAgainstRobot = false;

  TicTacToe(int boardSize) {
    size = boardSize;
    board = List.generate(size, (_) => List.filled(size, ' '));
  }

  void printBoard() {
    print('\n   ${List.generate(size, (i) => i).join('   ')}');
    for (int i = 0; i < size; i++) {
      String row = '$i ';
      for (int j = 0; j < size; j++) {
        row += ' ${board[i][j]} ';
        if (j < size - 1) row += '|';
      }
      print(row);
      if (i < size - 1) {
        print('  ${List.filled(size * 4 - 1, '-').join('')}');
      }
    }
    print('');
  }

  bool makeMove(int row, int col) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      return false;
    }
    if (board[row][col] != ' ') {
      return false;
    }
    board[row][col] = currentPlayer;
    return true;
  }

  String? checkWinForPlayer(String player) {
    // Проверка горизонталей
    for (int i = 0; i < size; i++) {
      if (board[i][0] == player) {
        bool win = true;
        for (int j = 1; j < size; j++) {
          if (board[i][j] != player) {
            win = false;
            break;
          }
        }
        if (win) {
          return player;
        }
      }
    }

    // Проверка вертикалей
    for (int j = 0; j < size; j++) {
      if (board[0][j] == player) {
        bool win = true;
        for (int i = 1; i < size; i++) {
          if (board[i][j] != player) {
            win = false;
            break;
          }
        }
        if (win) {
          return player;
        }
      }
    }

    // Проверка главной диагонали
    if (board[0][0] == player) {
      bool win = true;
      for (int i = 1; i < size; i++) {
        if (board[i][i] != player) {
          win = false;
          break;
        }
      }
      if (win) {
        return player;
      }
    }

    // Проверка побочной диагонали
    if (board[0][size - 1] == player) {
      bool win = true;
      for (int i = 1; i < size; i++) {
        if (board[i][size - 1 - i] != player) {
          win = false;
          break;
        }
      }
      if (win) {
        return player;
      }
    }

    return null;
  }

  bool checkWin() {
    String? xWinner = checkWinForPlayer('X');
    if (xWinner != null) {
      winner = 'X';
      return true;
    }
    
    String? oWinner = checkWinForPlayer('O');
    if (oWinner != null) {
      winner = 'O';
      return true;
    }

    return false;
  }

  bool checkDraw() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (board[i][j] == ' ') {
          return false;
        }
      }
    }
    return true;
  }

  void switchPlayer() {
    currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
  }

  List<int>? getRobotMove() {
    // Простая стратегия: сначала пытаемся выиграть, потом блокируем противника, иначе случайный ход
    
    // 1. Попытка выиграть
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (board[i][j] == ' ') {
          board[i][j] = 'O';
          if (checkWinForPlayer('O') != null) {
            board[i][j] = ' ';
            return [i, j];
          }
          board[i][j] = ' ';
        }
      }
    }

    // 2. Блокировка противника
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (board[i][j] == ' ') {
          board[i][j] = 'X';
          if (checkWinForPlayer('X') != null) {
            board[i][j] = ' ';
            return [i, j];
          }
          board[i][j] = ' ';
        }
      }
    }

    // 3. Случайный ход
    List<List<int>> availableMoves = [];
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (board[i][j] == ' ') {
          availableMoves.add([i, j]);
        }
      }
    }

    if (availableMoves.isNotEmpty) {
      Random random = Random();
      return availableMoves[random.nextInt(availableMoves.length)];
    }

    return null;
  }

  void reset() {
    board = List.generate(size, (_) => List.filled(size, ' '));
    isGameOver = false;
    winner = null;
  }
}

void main() {
  print('=== КРЕСТИКИ-НОЛИКИ ===\n');

  int? boardSize;
  while (boardSize == null || boardSize < 3) {
    stdout.write('Введите размер игрового поля (минимум 3): ');
    String? input = stdin.readLineSync();
    if (input != null) {
      boardSize = int.tryParse(input);
      if (boardSize == null || boardSize < 3) {
        print('Пожалуйста, введите число не меньше 3.\n');
      }
    }
  }

  bool playAgain = true;

  while (playAgain) {
    TicTacToe game = TicTacToe(boardSize);

    // Выбор режима игры
    print('\nВыберите режим игры:');
    print('1 - Игра против другого игрока');
    print('2 - Игра против робота');
    stdout.write('Ваш выбор (1 или 2): ');
    String? modeInput = stdin.readLineSync();
    
    if (modeInput == '2') {
      game.isAgainstRobot = true;
      print('\nВы играете против робота. Вы играете за X, робот за O.\n');
    } else {
      game.isAgainstRobot = false;
      print('\nРежим игры: два игрока.\n');
    }

    // Случайный выбор первого игрока
    Random random = Random();
    if (random.nextBool()) {
      game.currentPlayer = 'O';
      print('Первым ходит игрок O!\n');
    } else {
      game.currentPlayer = 'X';
      print('Первым ходит игрок X!\n');
    }

    // Если первый ход у робота
    if (game.isAgainstRobot && game.currentPlayer == 'O') {
      print('Робот делает ход...');
      List<int>? robotMove = game.getRobotMove();
      if (robotMove != null) {
        game.makeMove(robotMove[0], robotMove[1]);
        print('Робот поставил O в позицию (${robotMove[0]}, ${robotMove[1]})');
      }
      game.switchPlayer();
    }

    // Основной игровой цикл
    while (!game.isGameOver) {
      game.printBoard();

      if (game.isAgainstRobot && game.currentPlayer == 'O') {
        // Ход робота
        print('Робот делает ход...');
        List<int>? robotMove = game.getRobotMove();
        if (robotMove != null) {
          game.makeMove(robotMove[0], robotMove[1]);
          print('Робот поставил O в позицию (${robotMove[0]}, ${robotMove[1]})');
        }
      } else {
        // Ход игрока
        print('Ход игрока ${game.currentPlayer}');
        stdout.write('Введите строку (0-${game.size - 1}): ');
        String? rowInput = stdin.readLineSync();
        stdout.write('Введите столбец (0-${game.size - 1}): ');
        String? colInput = stdin.readLineSync();

        if (rowInput != null && colInput != null) {
          int? row = int.tryParse(rowInput);
          int? col = int.tryParse(colInput);

          if (row != null && col != null) {
            if (game.makeMove(row, col)) {
              // Ход успешен
            } else {
              print('Неверный ход! Попробуйте снова.\n');
              continue;
            }
          } else {
            print('Неверный ввод! Введите числа.\n');
            continue;
          }
        } else {
          print('Неверный ввод!\n');
          continue;
        }
      }

      // Проверка победы
      if (game.checkWin()) {
        game.isGameOver = true;
        game.printBoard();
        if (game.isAgainstRobot && game.winner == 'O') {
          print('Робот выиграл!');
        } else if (game.isAgainstRobot && game.winner == 'X') {
          print('Вы выиграли! Поздравляем!');
        } else {
          print('Игрок ${game.winner} выиграл!');
        }
        break;
      }

      // Проверка ничьей
      if (game.checkDraw()) {
        game.isGameOver = true;
        game.printBoard();
        print('Патовая ситуация! Ничья!');
        break;
      }

      game.switchPlayer();
    }

    // Предложение сыграть снова
    print('\nХотите сыграть еще раз? (да/нет): ');
    String? againInput = stdin.readLineSync();
    if (againInput == null || 
        againInput.toLowerCase() != 'да' && 
        againInput.toLowerCase() != 'yes' && 
        againInput.toLowerCase() != 'y' &&
        againInput.toLowerCase() != 'д') {
      playAgain = false;
      print('\nСпасибо за игру! До свидания!');
    } else {
      print('\nНачинаем новую игру!\n');
    }
  }
}
