import 'dart:collection';
import 'dart:math';


class Player {
  Player ({required this.name, required this.type});
  String name;
  PlayerType type;

  @override
  String toString() {
    return name;
  }
}


enum GameProgress {
  begin,
  process,
  end,
}


enum GameDifficulty {
  easy,
  medium,
  hard,
  impossible,
}


enum PlayerType {
  computer,
  human
}


class TicTacToe {
  final List<Player?> _cells = [
    null, null, null,
    null, null, null,
    null, null, null
  ];

  static const _winCells = [
    [0,1,2], [3,4,5], [6,7,8],
    [0,3,6], [1,4,7], [2,5,8],
    [0,4,8], [2,4,6]
  ];

  final Player xPlayer = Player(name: 'X', type: PlayerType.human);
  final Player oPlayer = Player(name: 'O', type: PlayerType.computer);
  late Player _currentPlayer;

  GameDifficulty difficulty;

  final _rand = Random.secure();


  TicTacToe({this.difficulty = GameDifficulty.medium}) {
    _currentPlayer = xPlayer;
  }

  
  TicTacToe.clone(TicTacToe o) 
    : difficulty = o.difficulty {
    
    for(int i=0; i<_cells.length; i++) {
      if (o._cells[i] == null) continue;
      _cells[i] = (o._cells[i] == o.xPlayer) ? xPlayer : oPlayer;
    }

    _currentPlayer = (o._currentPlayer == o.xPlayer) ? xPlayer : oPlayer;

    xPlayer.type = o.xPlayer.type;
    oPlayer.type = o.oPlayer.type;
    
  }

  
  Player get currentPlayer => _currentPlayer;

  
  UnmodifiableListView<Player?> get cells => UnmodifiableListView(_cells);

  
  // Return indices of winning cells
  List<int>? get winnerCells {
    for(final p in [xPlayer, oPlayer]) {
      for (final wc in _winCells) {
        bool isWinner =
            (_cells[wc[0]] == p) &&
            (_cells[wc[1]] == p) &&
            (_cells[wc[2]] == p);
        
        if (isWinner) return wc;
      }
    }
    return null;
  }

  // Number of vacant cells of the field
  int get vacantCellsCount {
    var res = 0;
    for (var i=0; i<_cells.length; i++) {
      res += (_cells[i] == null) ? 1 : 0;
    }
    return res;
  }

  
  Player? get winner {
    final wc = winnerCells;
    return (wc != null) ? _cells[wc[0]] : null;
  }

  
  bool get isDraw => (vacantCellsCount == 0) && (winner == null);

  
  bool get canMakeMove => (winner == null) && (vacantCellsCount > 0);

  
  GameProgress get progress {
    if (winner != null || isDraw) {
      return GameProgress.end;
    }
    else if (vacantCellsCount == 9) {
      return GameProgress.begin;
    }
    else {
      return GameProgress.process;
    }
  }

  
  void makeMove(int cellIndex) {
    if (!canMakeMove) return;

    if (cellIndex < 0 || cellIndex > 8) {
      throw ArgumentError('Invalid cell');
    }

    if (_cells[cellIndex] != null) {
      throw ArgumentError('Cell is already taken');
    }

    _cells[cellIndex] = _currentPlayer;
    _currentPlayer = _currentPlayer == xPlayer ? oPlayer : xPlayer;
  }

  
  // evaluate current game state for player p
  //   10 : p win
  //  -10 : p lose
  //    0 : draw
  // null : game is not finished
  int? score(Player p, int depth){
    final w = winner;
    if (w != null) {
        return (w == p) ? 10 - depth : depth - 10;
    }

    return isDraw ? 0 : null;
  }


  static int minimax(TicTacToe game, Player p, int depth) {
    int? curScore = game.score(p, depth);
    if (curScore != null) {
        return curScore;
    }

    final scores = {};

    Player np = p == game.xPlayer ? game.oPlayer : game.xPlayer;

    for(int i=0; i<game._cells.length; i++) {
      if(game._cells[i] != null) continue;
      game._cells[i] = p;
      int val = minimax(game, np, depth+1);
      scores[i] = -val;
      game._cells[i] = null;
    }

    int resValue = -1000000;
    scores.forEach((key, value) {
      if (value > resValue) {
        resValue = value;
      }
    });

    return resValue;
  }


  static List<int> getBestMoves(TicTacToe game, Player p) {
    assert(p == game.xPlayer || p == game.oPlayer);
    final scores = {};

    Player np = p == game.xPlayer ? game.oPlayer : game.xPlayer;

    for(int i=0; i<game._cells.length; i++) {
      if(game._cells[i] != null) continue;
      game._cells[i] = p;
      int val = minimax(game, np, 0);
      scores[i] = -val;
      game._cells[i] = null;
    }

    List<int> res = [];
    int bestValue = -1000000; // kind of INT_MIN

    scores.forEach((cellIndex, value) {
      if (value > bestValue) {
        bestValue = value;
        res.clear();
        res.add(cellIndex);
      }
      else if (value == bestValue){
        res.add(cellIndex);
      }
    });

    // print('scores: ' + scores.toString());
    // print('best  : ' + res.toString());
    return res;
  }


  int getBestMove() {
    if (vacantCellsCount == 0) {
      throw StateError('No available cells');
    }

    final game = TicTacToe.clone(this);
    final cells = getBestMoves(game, game.currentPlayer);
    return cells[_rand.nextInt(cells.length)];
  }


  int getRandomMove() {
    if (vacantCellsCount == 0) {
      throw StateError('No available cells');
    }

    int pos = _rand.nextInt(vacantCellsCount) + 1;

    for (var i=0; i<_cells.length; i++) {
      pos -= (_cells[i] == null) ? 1 : 0;
      if (pos == 0){
        return i;
      }
    }
    return -1;
  }


  int getNextMove([GameDifficulty? level]) {
    level ??= difficulty;

    assert([
      GameDifficulty.easy,
      GameDifficulty.medium,
      GameDifficulty.hard,
      GameDifficulty.impossible].contains(level));

    
    final rand = _rand.nextDouble();

    if (level == GameDifficulty.easy && rand <= 0.8) {
      return getRandomMove();
    }
    if (level == GameDifficulty.medium && rand <= 0.3) {
      return getRandomMove();
    }
    if (level == GameDifficulty.hard && rand <= 0.2) {
      return getRandomMove();
    }

    final game = TicTacToe.clone(this);
    final cells = getBestMoves(game, game.currentPlayer);
    return cells[_rand.nextInt(cells.length)];
  }


  @override
  String toString() {
    String res = '';
    for (int y=0; y<3; y++){
      String s = "";
      for (int x=0; x<3; x++){
        s += (_cells[y*3 + x]?.name ?? ' ') + ' ';
      }
      res += s;
    }
    return res;
  }

}



