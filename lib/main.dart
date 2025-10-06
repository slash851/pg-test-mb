import 'package:flutter/material.dart';
import 'package:pg_test/models.dart';
import 'package:pg_test/questions_data.dart';
import 'package:pg_test/quiz_screen.dart';

void main() {
  runApp(const ExamApp());
}

class ExamApp extends StatelessWidget {
  const ExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Świadectwo Kwalifikacji Pilota Paralotni',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Parse the raw data into our models
    final List<QuestionCategory> categories = questionsData.map((cat) => QuestionCategory.fromMap(cat)).toList();
    final List<Question> allQuestions = categories.expand((cat) => cat.questions).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Świadectwo Kwalifikacji Pilota Paralotni'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _MenuOption(
            title: '1. Praktyka',
            subtitle: 'Wszystkie pytania jedno po drugim.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    questions: allQuestions..shuffle(),
                    title: 'Praktyka',
                  ),
                ),
              );
            },
          ),
          _MenuOption(
            title: '2. Test',
            subtitle: '20 losowych pytań - 20 minut na odpowiedź.',
            onTap: () {
              final randomQuestions = (allQuestions..shuffle()).take(20).toList();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    questions: randomQuestions,
                    title: 'Test',
                    timeLimit: const Duration(minutes: 20),
                  ),
                ),
              );
            },
          ),
          _MenuOption(
            title: '3. Ćwicz z kategorii',
            subtitle: 'Wybierz kategorię pytań do ćwiczeń.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategorySelectionScreen(categories: categories),
                ),
              );
            },
          ),
          _MenuOption(
            title: '4. Przygotuj się',
            subtitle: 'Przejrzyj wszystkie pytania i prawidłowe odpowiedzi.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LearnScreen(categories: categories),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuOption({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class CategorySelectionScreen extends StatelessWidget {
  final List<QuestionCategory> categories;

  const CategorySelectionScreen({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Category'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(category.name),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      questions: category.questions,
                      title: category.name,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class LearnScreen extends StatelessWidget {
  final List<QuestionCategory> categories;

  const LearnScreen({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ExpansionTile(
            title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            children: category.questions.map((q) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.questionText, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (q.image != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.asset('assets/${q.image}'),
                      ),
                    ...List.generate(q.answers.length, (ansIndex) {
                      final isCorrect = ansIndex == q.correctAnswerIndex;
                      return ListTile(
                        title: Text(q.answers[ansIndex]),
                        tileColor: isCorrect ? Colors.green.withOpacity(0.3) : null,
                      );
                    }),
                    const Divider(),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
