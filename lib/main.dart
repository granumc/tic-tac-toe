import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/field.dart';
import 'package:tic_tac_toe/game.dart';
import 'package:tic_tac_toe/themes.dart';


void main() async {
  runApp(TicTacToeApp());
}


class TicTacToeApp extends StatelessWidget {
  // This widget is the root of the application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TicTacToeHome(),
    );
  }
}



class TicTacToeHome extends StatefulWidget {
  TicTacToeHome({Key? key}) : super(key: key);

  @override
  _TicTacToeHomeState createState() => _TicTacToeHomeState();
}


class _TicTacToeHomeState extends State<TicTacToeHome> {
  
  @override
  void initState() {
    super.initState();
    _game = TicTacToe();
    _loadAndApplySettings();
  }


  late TicTacToe _game;
  int _xWinCount = 0;
  int _oWinCount = 0;
  String _gameMode = "medium";
  AppTheme _appTheme = AppTheme.themes['Default']!;
  StrokeCap _themeStrokeCap = StrokeCap.round;

  final Duration _gridAnimationDuration = Duration(milliseconds: 1000);
  final Duration _cellAnimationDuration = Duration(milliseconds: 300);
  final Duration _endgameAnimationDuration = Duration(milliseconds: 2000);
  final Duration _computerMoveDelay = Duration(milliseconds: 250);


  static String _strokeCapToString(StrokeCap sc) {
    switch(sc) {
      case StrokeCap.butt: return 'butt';
      case StrokeCap.square: return 'square';
      case StrokeCap.round: return 'round';
    }
  }


  static StrokeCap? _strokeCapFromString(String? sc) {
    if (sc == 'butt') return StrokeCap.butt;
    if (sc == 'square') return StrokeCap.square;
    if (sc == 'round') return StrokeCap.round;
    return null;
  }


  static Color _darkenColor(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }


  static Color _lightenColor(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }


  void _loadAndApplySettings() {
    SharedPreferences.getInstance().then((prefs){
      final themeName = prefs.getString('appTheme');
      final theme = AppTheme.themes[themeName];
      final strokeCapName = prefs.getString('strokeCap');
      final StrokeCap sCap = _strokeCapFromString(strokeCapName) ?? StrokeCap.butt;

      if (mounted) {      
        setState(() {
          _themeStrokeCap = sCap;
          if (theme != null) _appTheme = theme;
        });
      }
      else {
        _themeStrokeCap = sCap;
        if (theme != null) _appTheme = theme;
      }

    }).onError((error, stackTrace){
      print('Error: Settings cannot be loaded');
    });
  }


  void _saveSettings() {
    SharedPreferences.getInstance().then((prefs){
      prefs.setString('appTheme', _appTheme.name);
      prefs.setString('strokeCap', _strokeCapToString(_themeStrokeCap));
    });
  }


  void _resetGame() {
    setState(() {
      final difficulty = _game.difficulty;
      _game = TicTacToe();
      _game.difficulty =  difficulty;
      _game.xPlayer.type = PlayerType.human;

      if (_gameMode == 'friend') {
        _game.oPlayer.type = PlayerType.human;
      }
      else {
        _game.oPlayer.type = PlayerType.computer;
      }
    });
  }


  bool _isValidGameMode(String? gameMode) {
    return 
      (gameMode != null)  &&
      ['easy', 'medium', 'hard', 'impossible', 'friend'].contains(gameMode);
  }


  void _changeGameMode(String mode){
    assert(_isValidGameMode(mode), 'Unknown game mode');

    _gameMode = mode;

    setState(() {
      _game = TicTacToe();
      _game.xPlayer.type = PlayerType.human;
      if (mode == 'friend'){
        _game.oPlayer.type = PlayerType.human;
      }
      else if (mode == 'easy') {
        _game.oPlayer.type = PlayerType.computer;
        _game.difficulty = GameDifficulty.easy;
      }
      else if (mode == 'medium') {
        _game.oPlayer.type = PlayerType.computer;
        _game.difficulty = GameDifficulty.medium;
      }
      else if (mode == 'hard') {
        _game.oPlayer.type = PlayerType.computer;
        _game.difficulty = GameDifficulty.hard;
      }
      else if (mode == 'impossible') {
        _game.oPlayer.type = PlayerType.computer;
        _game.difficulty = GameDifficulty.impossible;
      }
    });
  }


  void _chooseTheme(BuildContext context) {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context){
        return ChooseThemeDialog(themes:AppTheme.themes, appTheme: _appTheme, strokeCap: _themeStrokeCap);
      }
    ).then((value){
      if (value != null) {
        setState(() {
          _appTheme = value['theme'].value;
          _themeStrokeCap = value['strokeCap'];
        });

        _saveSettings();
      }
    });
  }


  // this function is called when the inner state of _game changed
  void _onGameChanged(Future<void>? animationEnded){
    setState(() {
      // rebuild the widget
    });
  }


  void _onGameEnded(Future<void>? animationEnded) {
    animationEnded?.then((value){
      setState((){
        if (_game.progress == GameProgress.end){
          if (_game.winner == _game.xPlayer) {
            _xWinCount++;
          }
          else if (_game.winner == _game.oPlayer) {
            _oWinCount++;
          } 
        }
      });

       _onGameChanged(null);
    });
  }


  void _onNewGameRequest() {
    _resetGame();
  }


  void _onXPlayerSelected(){
    _game.xPlayer.type = PlayerType.human;
    _game.oPlayer.type = PlayerType.computer;
  }


  void _onOPlayerSelected(){
    setState(() {
      _game.oPlayer.type = PlayerType.human;
      _game.xPlayer.type = PlayerType.computer;
      _game.makeMove(_game.getNextMove());
    });
  }


  Widget _hintWidget() {
    String caption;
    if (_game.progress == GameProgress.begin) {
      if (_gameMode == 'friend') {
        caption = 'Start game';
      }
      else {
        caption = "Start game or select player";
      }
    }
    else if (_game.progress == GameProgress.end) {
      caption = "Game over";
    }
    else {
      caption = _game.currentPlayer.name + "  Turn";
    }

    final text = Text(
      caption,
      style: Theme.of(context).textTheme.headline6?.copyWith(color: _appTheme.hintColor),
    );

    return text;
  }


  Widget _settingsButton(BuildContext context) {

    item(title, value) =>
      PopupMenuItem<String>(child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right:8.0),
            child: Icon((_gameMode == value) ?
              Icons.radio_button_checked : Icons.radio_button_unchecked),
          ),
          Text(title),
        ]),
      value: value);


    final List<PopupMenuItem<String>> items = [
      item("Easy", "easy"),
      item("Medium", "medium"),
      item("Hard", "hard"),
      item("Impossible", "impossible"),
      item("Play with a friend", "friend"),
    ];

    final chooseThemeItem = PopupMenuItem<String>(
      child: Text('Choose theme'),
      value: 'chooseTheme',
    );

    return PopupMenuButton<String>(
      icon: Icon(Icons.settings, color: _appTheme.captionColor),
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        ...items,
        PopupMenuDivider(),
        chooseThemeItem,
      ],
      onSelected: (String? newVal){
        if(newVal == 'chooseTheme'){
          _chooseTheme(context);
        }
        else {
          _changeGameMode(newVal ?? 'medium');
        }
      },
    );
  }


  Widget _selectPlayerButton(Player player, int winCount, void Function() onPressed){

    late final Color bgColor;
    if (_game.progress == GameProgress.end) {
      bgColor = _darkenColor(_appTheme.bgColor, 0.02);
    }
    else if (_game.currentPlayer == player) {
      bgColor = _lightenColor(_appTheme.bgColor, 0.05);
    }
    else {
      bgColor = _darkenColor(_appTheme.bgColor, 0.07);
    }
    
    return PlayerButton(
      player: player, 
      bgColor: bgColor, 
      winCount: winCount.toString(), 
      onPressed:onPressed);    
  }


  Widget _selectPlayerWidget(){
    return Container(
      padding: EdgeInsets.only(left:16, right: 16),
      // color: Colors.yellow,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 200, maxHeight: 40),
              child: SizedBox.expand(
                child: _selectPlayerButton(_game.xPlayer, _xWinCount, _onXPlayerSelected),
              )
            ),
          ),
          Container(width: 24),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 200, maxHeight: 40),
              child: SizedBox.expand(
                child: _selectPlayerButton(_game.oPlayer, _oWinCount, _onOPlayerSelected),
              )
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: AnimatedContainer( // Container(
          duration: Duration(milliseconds: 1000),
          color: _appTheme.bgColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 32, 0, 18),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Container()),
                    Expanded(flex: 2, child: Center(child: Text("Tic Tac Toe", style: Theme.of(context).textTheme.headline4?.copyWith(color: _appTheme.captionColor),))),
                    Expanded(flex: 1, child: _settingsButton(context)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top:24.0, bottom: 12),
                child: IgnorePointer(
                  child: _selectPlayerWidget(),
                  ignoring:
                    (_game.progress != GameProgress.begin) ||
                    (_gameMode == 'friend')),
              ),

              Padding(
                padding: EdgeInsets.all(24),
                child: _hintWidget(),
              ),

              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Field(
                    game: _game, 
                    onGameChanged: _onGameChanged,
                    onGameEnded: _onGameEnded,
                    onNewGameRequest: _onNewGameRequest,
                    xColor: _appTheme.xColor,
                    oColor: _appTheme.oColor,
                    gridColor: _appTheme.gridColor,
                    textColor: _appTheme.textColor,
                    strokeCap: _themeStrokeCap,
                    gridAnimationDuration: _gridAnimationDuration,
                    cellAnimationDuration: _cellAnimationDuration,
                    endgameAnimationDuration: _endgameAnimationDuration,
                    computerMoveDelay: _computerMoveDelay,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(0,0,0,32),
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

}



class PlayerButton extends StatefulWidget {
  const PlayerButton({ 
    Key? key, 
    required this.player,
    required this.bgColor,
    this.winCount = '',
    required this.onPressed
  }) : super(key: key);

  final Player player;
  final Color bgColor;
  final String winCount;

  final void Function() onPressed;

  @override
  _PlayerButtonState createState() => _PlayerButtonState();
}


class _PlayerButtonState extends State<PlayerButton>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<Color?> bgColor;
  late Animation<Color?> textColor;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, value: 0.0, duration: Duration(milliseconds: 300));
    _controller.addListener(() {setState(() { });});
    bgColor = ConstantTween<Color>(widget.bgColor).animate(_controller);
    textColor= ConstantTween<Color>(_textColor(widget.bgColor)).animate(_controller);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(PlayerButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.bgColor != widget.bgColor) {
      bgColor = ColorTween(begin: bgColor.value, end: widget.bgColor).animate(_controller);
      textColor = ColorTween(begin: textColor.value, end: _textColor(widget.bgColor)).animate(_controller);
      _controller.reset();
      _controller.forward();
    }
  }

  Color _textColor(Color bgColor) {
    final brightness = ((bgColor.red * 299) +
                      (bgColor.green * 587) +
                      (bgColor.blue * 114)) / 1000;
    final textColour = (brightness > 160.0 /*125.0*/) ? Colors.black : Colors.white;
    return textColour;
  }


  @override
  Widget build(BuildContext context) {
    final double elevation = 2.0;

    final IconData playerTypeIcon = (widget.player.type == PlayerType.computer)
      ? Icons.computer
      : Icons.person;

    final IconData playerIcon = (widget.player.name == 'X')
      ? Icons.close
      : Icons.circle_outlined;

    final style = ElevatedButton.styleFrom(
      primary: bgColor.value, 
      elevation: elevation);

    final textColor = this.textColor.value;
    final textStyleWinCount = TextStyle(color: textColor);

    return ElevatedButton(
      style: style,
      onPressed: widget.onPressed,
      child:  Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(playerIcon, color:textColor),
            Icon(playerTypeIcon, color: textColor),
            Text(widget.winCount, textScaleFactor: 1.2, style: textStyleWinCount)
          ],
        )
      ),
    );
  }

}



class ChooseThemeDialog extends StatefulWidget {
  const ChooseThemeDialog({ 
    Key? key, 
    required this.themes,
    required this.appTheme, 
    required this.strokeCap
  }) : super(key: key);

  final Map<String, AppTheme> themes;
  final AppTheme appTheme;
  final StrokeCap strokeCap;

  @override
  _ChooseThemeDialogState createState() => _ChooseThemeDialogState();
}


class _ChooseThemeDialogState extends State<ChooseThemeDialog> {

  @override
  void initState() {
    super.initState();
    appTheme = widget.appTheme;
    strokeCap = widget.strokeCap;
  }

  late AppTheme appTheme;
  late StrokeCap strokeCap;

  final game = TicTacToe()..makeMove(0)..makeMove(1)..makeMove(4)..makeMove(3);


  Widget gridItem(MapEntry<String, AppTheme> theme) {
    return GridTile(
      child: GestureDetector(
        onTap: () { 
          final res = {'themeName':theme.key, 'theme': theme, 'strokeCap':strokeCap};
          Navigator.pop(context, res);
        },
        child: Container(
          color: theme.value.bgColor,
          padding: EdgeInsets.all(8),
          child: AbsorbPointer(
            child: Field(
              game: game, 
              animateGridOnCreate: false,
              gridColor: theme.value.gridColor,
              xColor: theme.value.xColor,
              oColor: theme.value.oColor,
            ),
          ),
        ),
      )
    );
  }

 
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Choose theme') ,
      titleTextStyle: Theme.of(context).textTheme.headline5,
      children: [
        Divider(),
        Container(
          // color: Colors.amber,
          height: 400,
          width: 400,
          child: GridView.count(
            padding: EdgeInsets.all(24),
            crossAxisCount: 2,
            mainAxisSpacing: 32,
            crossAxisSpacing: 32,
            children: [
              for(var t in widget.themes.entries)
                gridItem(t),
            ],
          ),
        ),

        Divider(height: 24,),

        Row(
          children: [
            Switch(value: strokeCap == StrokeCap.round, onChanged: (val) { 
              setState(() {
                strokeCap = (val) ? StrokeCap.round : StrokeCap.square;   
              });
            }),
            Text('Round edges')
          ],
        )
      ],
    );
  }
}