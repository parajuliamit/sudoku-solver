import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<List<int?>> demo =
      List.generate(9, (index) => List.generate(9, (i) => null));
  final FocusNode _focusNode = FocusNode();
  Map<String, int>? _selectedTile;

  _moveFocus(int x, int y) {
    if (_selectedTile != null) {
      int newRow = _selectedTile!['row']! + y;
      int newCol = _selectedTile!['column']! + x;
      if (newCol >= 0 && newCol < 9 && newRow >= 0 && newRow < 9) {
        setState(() {
          _selectedTile = {
            'row': newRow,
            'column': newCol,
          };
        });
      }
    }
  }

  bool possible(int row, int col, int number) {
    for (int i = 0; i < 9; i++) {
      if (demo[row][i] == number) {
        return false;
      }
      if (demo[i][col] == number) {
        return false;
      }
    }
    int boxRowStart = (row ~/ 3) * 3;
    int boxColStart = (col ~/ 3) * 3;
    for (int i = boxRowStart; i < boxRowStart + 3; i++) {
      for (int j = boxColStart; j < boxColStart + 3; j++) {
        if (demo[i][j] == number) {
          return false;
        }
      }
    }
    return true;
  }

  void solve() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (demo[i][j] == null) {
          for (int k = 1; k < 10; k++) {
            if (possible(i, j, k)) {
              demo[i][j] = k;
              solve();
              demo[i][j] = null;
            }
          }
          return;
        }
      }
    }
    throw Exception('Solution found');
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Solution'),
          content: const Text('No solution found'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final smallSide = size.width < size.height ? size.width : size.height;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RawKeyboardListener(
                focusNode: _focusNode,
                onKey: (event) {
                  if (event.runtimeType == RawKeyDownEvent) {
                    final key = event.data.logicalKey;
                    final int? value = int.tryParse(key.keyLabel);
                    if (value != null) {
                      if (value > 0) {
                        if (_selectedTile != null) {
                          setState(() {
                            demo[_selectedTile!['row']!]
                                [_selectedTile!['column']!] = value;
                          });
                          return;
                        }
                      }
                    }
                    if (key.keyId == LogicalKeyboardKey.backspace.keyId ||
                        key.keyId == LogicalKeyboardKey.delete.keyId) {
                      if (_selectedTile != null) {
                        setState(() {
                          demo[_selectedTile!['row']!]
                              [_selectedTile!['column']!] = null;
                        });
                      }
                      return;
                    }
                    if (key.keyId == LogicalKeyboardKey.arrowUp.keyId) {
                      _moveFocus(0, -1);
                    } else if (key.keyId ==
                        LogicalKeyboardKey.arrowDown.keyId) {
                      _moveFocus(0, 1);
                    } else if (key.keyId ==
                        LogicalKeyboardKey.arrowLeft.keyId) {
                      _moveFocus(-1, 0);
                    } else if (key.keyId ==
                        LogicalKeyboardKey.arrowRight.keyId) {
                      _moveFocus(1, 0);
                    } else if (key.keyId == LogicalKeyboardKey.enter.keyId) {
                      _focusNode.unfocus();
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  width: smallSide * 0.75,
                  height: smallSide * 0.75,
                  child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 9,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemBuilder: (contex, index) => Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: 9,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3),
                              itemBuilder: (contex, i) => GestureDetector(
                                    onTap: () {
                                      _focusNode.requestFocus();
                                      setState(() {
                                        _selectedTile = {
                                          'row': (index ~/ 3) * 3 + (i ~/ 3),
                                          'column': (index % 3) * 3 + (i % 3)
                                        };
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _selectedTile != null &&
                                                _selectedTile!['row'] ==
                                                    (index ~/ 3) * 3 +
                                                        (i ~/ 3) &&
                                                _selectedTile!['column'] ==
                                                    (index % 3) * 3 + (i % 3)
                                            ? Colors.blue.withOpacity(0.5)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Center(
                                          child: Text(
                                        (demo[(index ~/ 3) * 3 + (i ~/ 3)][
                                                    (index % 3) * 3 +
                                                        (i % 3)] ??
                                                '')
                                            .toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18),
                                      )),
                                    ),
                                  )))),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _selectedTile = null;
                      });
                      _focusNode.unfocus();
                      try {
                        solve();
                        _showDialog();
                      } on Exception catch (e) {
                        print(e);
                      }
                    },
                    child: const Text('SOLVE'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTile = null;
                      });
                      _focusNode.unfocus();
                      setState(() {
                        demo = List.generate(
                            9, (index) => List.generate(9, (i) => null));
                      });
                    },
                    child: const Text('CLEAR'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
