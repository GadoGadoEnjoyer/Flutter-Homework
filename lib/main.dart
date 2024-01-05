import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MinesweeperGame(),
    );
  }
}

class MinesweeperGame extends StatefulWidget {
  @override
  _MinesweeperGameState createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<MinesweeperGame> {
  int rows = 10;
  int cols = 10;
  int numMines = 20;
  late List<List<bool>> isMine;
  late List<List<bool>> isRevealed;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    isMine = List.generate(rows, (_) => List.generate(cols, (_) => false));
    isRevealed = List.generate(rows, (_) => List.generate(cols, (_) => false));

    // Place mines randomly
    final random = Random();
    int minesPlaced = 0;
    while (minesPlaced < numMines) {
      int row = random.nextInt(rows);
      int col = random.nextInt(cols);
      if (!isMine[row][col]) {
        isMine[row][col] = true;
        minesPlaced++;
      }
    }
  }

  int countAdjacentMines(int row, int col) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        int r = row + dr;
        int c = col + dc;
        if (r >= 0 && r < rows && c >= 0 && c < cols && isMine[r][c]) {
          count++;
        }
      }
    }
    return count;
  }

  void revealTile(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols || isRevealed[row][col] || isGameOver) {
      return;
    }

    isRevealed[row][col] = true;
    
    if (isMine[row][col]) {
      // Game over when a mine is clicked
      setState(() {
        isGameOver = true;
      });
    } else {
      if (countAdjacentMines(row, col) == 0) {
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            revealTile(row + dr, col + dc);
          }
        }
      }
    }
  }

  Widget buildGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 2.0,
      ),
      itemBuilder: (context, index) {
        int row = index ~/ cols;
        int col = index % cols;
        int adjacentMines = countAdjacentMines(row, col);
        return GestureDetector(
          onTap: () {
            setState(() {
              revealTile(row, col);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: isRevealed[row][col] ? Colors.grey : Colors.blue,
            ),
            child: Center(
              child: isRevealed[row][col]
                  ? (isMine[row][col]
                      ? Icon(Icons.brightness_1, color: Colors.red)
                      : (adjacentMines > 0
                          ? Text(
                              adjacentMines.toString(),
                              style: TextStyle(fontSize: 18.0),
                            )
                          : null))
                  : null,
            ),
          ),
        );
      },
      itemCount: rows * cols,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minesweeper'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: buildGrid()),
          if (isGameOver)
            Container(
              color: Colors.red,
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Game Over!',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  
}
