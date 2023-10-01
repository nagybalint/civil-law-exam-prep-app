import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Question {
  final String question;
  final List<String> answers;
  final int correct;
  Question(this.question, this.answers, this.correct);
  static fromJsonElem(Map elem) {
    return Question(
        elem['question'],
        (elem['answers'] as List<dynamic>).map((e) => e.toString()).toList(),
        elem['correct']);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CurrentQuestionState(),
      child: MaterialApp(
        title: 'Polgárjog kikérdező',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: TestingPage(),
      ),
    );
  }
}

class CurrentQuestionState extends ChangeNotifier {
  int? questionNumber;
  int? selectedAnswer;
  bool isChecked = false;
  int questionId = 0;

  void selectAnswer(int? id) {
    selectedAnswer = id;
    notifyListeners();
  }

  void stepQuestion() {
    selectedAnswer = null;
    isChecked = false;
    questionId += 1;
    notifyListeners();
  }

  void checkAnswer() {
    if (selectedAnswer != null) {
      isChecked = true;
      notifyListeners();
    }
  }
}

class TestingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TestingPageState();
  }
}

class _TestingPageState extends State<TestingPage> {
  // ignore: prefer_typing_uninitialized_variables
  final List<Question> questions = List.empty(growable: true);

  Future<void> loadJsonAsset() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/questions.json');
    List data = jsonDecode(jsonString);
    setState(() {
      for (var element in data) {
        questions.add(Question.fromJsonElem(element));
      }
      questions.shuffle();
    });
  }

  @override
  void initState() {
    super.initState();
    loadJsonAsset();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<CurrentQuestionState>();
    var questionId = appState.questionId;
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Center(
          child: questions.isNotEmpty
              ? QuestionWidget(
                  question: questions[questionId % questions.length])
              : CircularProgressIndicator()),
    );
  }
}

class QuestionWidget extends StatefulWidget {
  const QuestionWidget({super.key, required this.question});

  final Question question;

  @override
  State<StatefulWidget> createState() {
    return _QuestionWidgetState();
  }
}

class _QuestionWidgetState extends State<QuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QuestionTextWidget(questionText: widget.question.question),
        AnswersWidget(
            answers: widget.question.answers,
            correctAnswerId: widget.question.correct),
        SubmitWidget()
      ],
    );
  }
}

class QuestionTextWidget extends StatelessWidget {
  const QuestionTextWidget({super.key, required this.questionText});

  final String questionText;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<CurrentQuestionState>();
    var questionId = appState.questionId;
    return Container(
        padding: const EdgeInsets.all(16),
        child: Text("${questionId + 1}. $questionText",
            style: TextStyle(
              fontSize: 25,
            )));
  }
}

class AnswersWidget extends StatefulWidget {
  const AnswersWidget(
      {super.key, required this.answers, required this.correctAnswerId});

  final List<String> answers;
  final int correctAnswerId;

  @override
  State<StatefulWidget> createState() {
    return _AnswersWidgetState();
  }
}

class _AnswersWidgetState extends State<AnswersWidget> {
  Color getBackground(int? selectedAnswer, int id, bool isChecked) {
    if (isChecked) {
      if (id == widget.correctAnswerId) {
        return Color.fromARGB(255, 156, 248, 149);
      } else if (id == selectedAnswer) {
        return Color.fromARGB(255, 255, 155, 148);
      }
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<CurrentQuestionState>();
    var selectedAnswer = appState.selectedAnswer;
    var isChecked = appState.isChecked;
    var ch = widget.answers
        .asMap()
        .map((i, a) => MapEntry(
            i,
            ListTile(
              onTap: isChecked
                  ? null
                  : () => {
                        if (i != selectedAnswer) {appState.selectAnswer(i)}
                      },
              tileColor: getBackground(selectedAnswer, i, isChecked),
              title: Text(a),
              leading: Radio(
                  groupValue: selectedAnswer,
                  value: i,
                  onChanged: isChecked ? null : (int? value) => {}),
            )))
        .values
        .toList();
    return Expanded(
      child: ListView(
        children: ch,
      ),
    );
  }
}

class SubmitWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SubmitWidgetState();
  }
}

class _SubmitWidgetState extends State<SubmitWidget> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<CurrentQuestionState>();
    var selectedAnswer = appState.selectedAnswer;
    var isChecked = appState.isChecked;
    return Container(
        padding: const EdgeInsets.all(32),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: (selectedAnswer == null || isChecked)
                    ? null
                    : () => appState.checkAnswer(),
                label: Text("Ellenőrzés"),
                icon: Icon(Icons.check),
              )),
          Container(
              padding: const EdgeInsets.only(left: 10),
              child: ElevatedButton.icon(
                onPressed: !isChecked ? null : () => appState.stepQuestion(),
                label: Text("Következő"),
                icon: Icon(Icons.arrow_right),
              ))
        ]));
  }
}
