import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TodoListApp());
}

class TodoListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'TODO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _todoItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString('items') ?? '[]';
    setState(() {
      _todoItems = List<Map<String, dynamic>>.from(jsonDecode(itemsJson));
    });
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = jsonEncode(_todoItems);
    prefs.setString('items', itemsJson);
  }

  void _addTodoItem(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _todoItems.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'task': task,
          'completed': false,
          'addedAt': DateFormat('dd.MM.yyyy      HH:mm').format(DateTime.now()),
        });
      });
      _controller.clear();
      _saveData();
    }
  }

  void _deleteTodoItem(dynamic id) {
    setState(() {
      _todoItems.removeWhere((item) => item['id'] == id.toString());
    });
    _saveData();
  }

  void _toggleTodoItem(dynamic id) {
    setState(() {
      final item = _todoItems.firstWhere((item) => item['id'] == id.toString());
      item['completed'] = !item['completed'];
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          decoration: const BoxDecoration(
              gradient: RadialGradient(colors: [
            Color.fromARGB(82, 161, 217, 255),
            Color.fromARGB(82, 203, 130, 248),
            Color.fromARGB(82, 237, 147, 202),
            Color.fromARGB(82, 242, 187, 187)
          ])),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  onSubmitted: _addTodoItem,
                  decoration: const InputDecoration(
                    labelText: 'Введите какую-нибудь задачу...',
                    hintText: 'например купить яхту',
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _todoItems.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(
                        _todoItems[index]['task'],
                        style: TextStyle(
                            decoration: _todoItems[index]['completed']
                                ? TextDecoration.lineThrough
                                : null),
                      ),
                      subtitle: Text('${_todoItems[index]['addedAt']}'),
                      value: _todoItems[index]['completed'],
                      onChanged: (bool? value) {
                        _toggleTodoItem(_todoItems[index]['id']);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _deleteTodoItem(_todoItems[index]['id']),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}