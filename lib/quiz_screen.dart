import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pg_test/models.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String title;
  final Duration? timeLimit;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.title,
    this.timeLimit,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _answered = false;

  Timer? _timer;
  Duration? _timeLeft;

  @override
  void initState() {
    super.initState();
    if (widget.timeLimit != null) {
      _timeLeft = widget.timeLimit;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft!.inSeconds > 0) {
        setState(() {
          _timeLeft = Duration(seconds: _timeLeft!.inSeconds - 1);
        });
      } else {
        _timer?.cancel();
        _showSummary();
      }
    });
  }

  void _handleAnswer(int selectedIndex) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedAnswerIndex = selectedIndex;
      if (selectedIndex == widget.questions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      _timer?.cancel();
      _showSummary();
    }
  }

  void _showSummary() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz zakończony!'),
        content: Text('Twój wynik: $_score / ${widget.questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Go back to the previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.questions.length,
            backgroundColor: Colors.grey[300],
          ),
        ),
        actions: [
          if (_timeLeft != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${_timeLeft!.inMinutes.toString().padLeft(2, '0')}:${(_timeLeft!.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pytanie ${_currentQuestionIndex + 1} / ${widget.questions.length}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              currentQuestion.categoryName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${currentQuestion.questionNumberInCategory}. ${currentQuestion.questionText}',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (currentQuestion.image != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Image.asset('assets/${currentQuestion.image}'),
              ),
            const SizedBox(height: 24),
            ...List.generate(currentQuestion.answers.length, (index) {
              Color? tileColor;
              if (_answered) {
                if (index == currentQuestion.correctAnswerIndex) {
                  tileColor = Colors.green.withOpacity(0.5);
                } else if (index == _selectedAnswerIndex) {
                  tileColor = Colors.red.withOpacity(0.5);
                }
              }

              return Card(
                color: tileColor,
                child: ListTile(
                  title: Text('${String.fromCharCode('A'.codeUnitAt(0) + index)}. ${currentQuestion.answers[index]}'),
                  onTap: () => _handleAnswer(index),
                ),
              );
            }),
            const Spacer(),
            if (_answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('NASTĘPNE PYTANIE'),
              ),
          ],
        ),
      ),
    );
  }
}
