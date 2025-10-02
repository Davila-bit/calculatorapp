import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Calculator state variables
  String _display = '0';
  String _previousValue = '';
  String _operator = '';
  bool _waitingForOperand = false;
  bool _isDarkMode = false;
  final List<String> _history = [];

  // Haptic feedback for button presses
  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  // Clear all calculator state
  void _clear() {
    setState(() {
      _display = '0';
      _previousValue = '';
      _operator = '';
      _waitingForOperand = false;
    });
    _hapticFeedback();
  }

  // Handle number button presses
  void _onNumberPressed(String number) {
    setState(() {
      if (_waitingForOperand) {
        _display = number;
        _waitingForOperand = false;
      } else {
        _display = _display == '0' ? number : _display + number;
      }
    });
    _hapticFeedback();
  }

  // Handle operator button presses
  void _onOperatorPressed(String operator) {
    if (_operator.isNotEmpty && !_waitingForOperand) {
      _calculate();
    }
    
    setState(() {
      _previousValue = _display;
      _operator = operator;
      _waitingForOperand = true;
    });
    _hapticFeedback();
  }

  // Perform calculation
  void _calculate() {
    if (_operator.isEmpty || _previousValue.isEmpty) return;

    double firstNumber = double.parse(_previousValue);
    double secondNumber = double.parse(_display);
    double result = 0;

    try {
      switch (_operator) {
        case '+':
          result = firstNumber + secondNumber;
          break;
        case '-':
          result = firstNumber - secondNumber;
          break;
        case '×':
          result = firstNumber * secondNumber;
          break;
        case '÷':
          if (secondNumber == 0) {
            _showError('Cannot divide by zero');
            return;
          }
          result = firstNumber / secondNumber;
          break;
      }

      // Add to history
      String calculation = '$_previousValue $_operator $_display = ${_formatResult(result)}';
      setState(() {
        _history.insert(0, calculation);
        if (_history.length > 10) {
          _history.removeLast();
        }
      });

      setState(() {
        _display = _formatResult(result);
        _operator = '';
        _previousValue = '';
        _waitingForOperand = true;
      });
    } catch (e) {
      _showError('Invalid calculation');
    }
    _hapticFeedback();
  }

  // Format result to avoid unnecessary decimal places
  String _formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    }
    return result.toString();
  }

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Toggle dark mode
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _hapticFeedback();
  }

  // Show history dialog
  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calculation History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _history.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  _history[index],
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _history.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear History'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    _hapticFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
        appBar: AppBar(
          title: const Text('Calculator App'),
          backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.deepPurple,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _history.isNotEmpty ? _showHistory : null,
            ),
          ],
        ),
        body: Column(
          children: [
            // Display area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_previousValue.isNotEmpty && _operator.isNotEmpty)
                    Text(
                      '$_previousValue $_operator',
                      style: TextStyle(
                        fontSize: 18,
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _display,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Button grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // First row: Clear, operators
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('C', _isDarkMode ? Colors.red[700] : Colors.red[500], _clear),
                          _buildButton('÷', _isDarkMode ? Colors.orange[700] : Colors.orange[500], () => _onOperatorPressed('÷')),
                          _buildButton('×', _isDarkMode ? Colors.orange[700] : Colors.orange[500], () => _onOperatorPressed('×')),
                          _buildButton('⌫', _isDarkMode ? Colors.grey[600] : Colors.grey[500], () {
                            setState(() {
                              if (_display.length > 1) {
                                _display = _display.substring(0, _display.length - 1);
                              } else {
                                _display = '0';
                              }
                            });
                            _hapticFeedback();
                          }),
                        ],
                      ),
                    ),
                    // Second row: 7, 8, 9, -
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('7', _isDarkMode ? Colors.grey[700] : Colors.grey[300], () => _onNumberPressed('7')),
                          _buildButton('8', _isDarkMode ? Colors.grey[700] : Colors.grey[300], () => _onNumberPressed('8')),
                          _buildButton('9', _isDarkMode ? Colors.grey[700] : Colors.grey[300], () => _onNumberPressed('9')),
                          _buildButton('-', _isDarkMode ? Colors.orange[700] : Colors.orange[500], () => _onOperatorPressed('-')),
                        ],
                      ),
                    ),
                    // Third row: 4, 5, 6, +
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('4', _isDarkMode ? Colors.grey[700] : Colors.grey[300], () => _onNumberPressed('4')),
                          _buildButton('5', _isDarkMode ? Colors.grey[700] : Colors.grey[300], () => _onNumberPressed('5')),
                          _buildButton('6', _isDarkMode ? Colors.grey[700] : Colors.grey[300], () => _onNumberPressed('6')),
                          _buildButton('+', _isDarkMode ? Colors.orange[700] : Colors.orange[500], () => _onOperatorPressed('+')),
                        ],
                      ),
                    ),
                    // Fourth row: 1, 2, 3, =
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('1', _isDarkMode ? Colors.grey[700] : Colors.grey[300], () => _onNumberPressed('1')),
                          _buildButton('2', _isDarkMode ? Colors.grey[700] : Colors.grey[300], () => _onNumberPressed('2')),
                          _buildButton('3', _isDarkMode ? Colors.grey[700] : Colors.grey[300], () => _onNumberPressed('3')),
                          _buildButton('=', _isDarkMode ? Colors.green[700] : Colors.green[500], _calculate, isEquals: true),
                        ],
                      ),
                    ),
                    // Fifth row: 0 (spans two columns)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildButton('0', _isDarkMode ? Colors.grey[700] : Colors.grey[300], () => _onNumberPressed('0')),
                          ),
                          _buildButton('.', _isDarkMode ? Colors.grey[700] : Colors.grey[300], () {
                            if (!_display.contains('.')) {
                              setState(() {
                                _display += '.';
                              });
                              _hapticFeedback();
                            }
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build individual calculator buttons
  Widget _buildButton(String text, Color? color, VoidCallback onPressed, {bool isEquals = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isEquals ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
