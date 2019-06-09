import 'package:flutter/material.dart';
import 'package:flutter_tags/selectable_tags.dart';

class AdicionarTag extends StatefulWidget {
  final String nmRepositorio;
  final List languages;

  const AdicionarTag({Key key, this.nmRepositorio, this.languages})
      : super(key: key);

  @override
  _AdicionarTagState createState() => _AdicionarTagState();
}

class _AdicionarTagState extends State<AdicionarTag> {
  List<Tag> _tags = [];


  @override
  Widget build(BuildContext context) {
    print('Qtd. Languages:' + widget.languages.toString());
    return Center(
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          children: <Widget>[
            Text("Selecione as TAGs que deseja adicionar ao repositorio " +
                widget.nmRepositorio),
            TextField(
              autofocus: true,
              decoration: InputDecoration(labelText: 'Task Title*'),
              //controller: taskTitleInputController,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Task Description*'),
              //controller: taskDescripInputController,
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancelar'),
              onPressed: () {
                //taskTitleInputController.clear();
                //taskDescripInputController.clear();
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text('Adicionar'),
              onPressed: () {
                /*
                if (taskDescripInputController.text.isNotEmpty &&
                    taskTitleInputController.text.isNotEmpty) {
                  Firestore.instance
                      .collection('tasks')
                      .add({
                        "title": taskTitleInputController.text,
                        "description": taskDescripInputController.text
                      })
                      .then((result) => {
                            Navigator.pop(context),
                            taskTitleInputController.clear(),
                            taskDescripInputController.clear(),
                          })
                      .catchError((err) => print(err));
                }
                */
              })
        ],
      ),
    );
  }
}
