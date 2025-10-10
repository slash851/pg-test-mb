class QuestionCategory {
  final String name;
  final List<Question> questions;

  QuestionCategory({required this.name, required this.questions});

  factory QuestionCategory.fromMap(Map<String, dynamic> map) {
    var questionsList = map['questions'] as List;
    List<Question> questions =
        questionsList.asMap().entries.map((entry) => Question.fromMap(entry.value, map['category'], entry.key + 1)).toList();

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
  final String categoryName;
  final int questionNumberInCategory;

  Question({
    required this.questionText,
    required this.answers,
    required this.correctAnswerIndex,
    this.image,
    required this.categoryName,
    required this.questionNumberInCategory,
  });

  factory Question.fromMap(Map<String, dynamic> map, String categoryName, int questionNumber) {
    return Question(
      questionText: map['question'],
      answers: List<String>.from(map['answers']),
      correctAnswerIndex: map['correctAnswer'],
      image: map['image'],
      categoryName: categoryName,
      questionNumberInCategory: questionNumber,
    );
  }
}
