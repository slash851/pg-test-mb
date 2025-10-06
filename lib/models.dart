class QuestionCategory {
  final String name;
  final List<Question> questions;

  QuestionCategory({required this.name, required this.questions});

  factory QuestionCategory.fromMap(Map<String, dynamic> map) {
    var questionsList = map['questions'] as List;
    List<Question> questions = questionsList.map((q) => Question.fromMap(q)).toList();
    return QuestionCategory(
      name: map['category'],
      questions: questions,
    );
  }
}

class Question {
  final String questionText;
  final List<String> answers;
  final int correctAnswerIndex;
  final String? image;

  Question({
    required this.questionText,
    required this.answers,
    required this.correctAnswerIndex,
    this.image,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['question'],
      answers: List<String>.from(map['answers']),
      correctAnswerIndex: map['correctAnswer'],
      image: map['image'],
    );
  }
}
