import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hub/adicionar_tag.dart';
import 'package:flutter_hub/data/Database.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tags/selectable_tags.dart';
import 'package:flutter_hub/data/TagModel.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp();

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      uri: 'https://api.github.com/graphql',
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer bf2933fc3ff8ec9c5fa86bf425d094c70835f03f',
    );

    final Link link = authLink.concat(httpLink as Link);

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: InMemoryCache(),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: CacheProvider(
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.amber,
          ),
          home: MyHomePage(
            title: 'Flutter Demo Home Page',
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController txtUsuario = new TextEditingController();

  _printLatestValue() {
    print("Second text field: ${txtUsuario.text}");
  }

  retornaQtdTags() async {
    int qtdTags = await DBProvider.db.getQtdTags();
    print('Qtd. Tags: ' + qtdTags.toString());
  }

  void _addTag() {
    TagModel tag = new TagModel();
    tag.nmTag = 'TESTE TAG';
    tag.nmRepositorio = 'TESTE';
    tag.nmUsuario = 'alessandrosilva';
    DBProvider.db.newTag(tag);
  }

  _showDialog(String nmRepositorio, List languages) async =>
      await showDialog<String>(
          context: context,
          builder: (_) => Center(
                  child: Container(
                width: 600.0,
                height: double.infinity,
                child: AdicionarTag(
                  nmRepositorio: nmRepositorio,
                  languages: languages,
                ),
              )));

  @override
  void initState() {
    txtUsuario.addListener(_printLatestValue());
    super.initState();
  }

  @override
  void dispose() {
    txtUsuario.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage("assets/bg_brainn.png"),
                repeat: ImageRepeat.repeat),
          ),
          child: Column(
            children: <Widget>[
              Container(
                child: Card(
                  child: ListTile(
                    trailing: GestureDetector(
                      child: Icon(Icons.search),
                      onTap: () => _searchStaredRepository(),
                    ),
                    title: TextFormField(
                      onFieldSubmitted: (value) => _searchStaredRepository(),
                      controller: txtUsuario,
                      decoration: InputDecoration(
                          labelText: 'Informe o nome do usuário'),
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
              ),
              Expanded(child: Container(child: _searchStaredRepository())),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: _printLatestValue(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Query _searchStaredRepository() {
    if (txtUsuario.text != "") {
      print(this.txtUsuario.text);

      String qry = "";

      setState(() {
        qry = """
query {
user(login: """ +
            txtUsuario.text +
            """) {
    login
    name
    avatarUrl
    starredRepositories(last: 100) {
      edges {
        cursor
        node {
          id
          name
          description
          url
          stargazers{
            totalCount
          }
          primaryLanguage {
            id
            name
            color
          }
          languages(last:10){
            nodes{
              id
              name
              color
            }
          }
        }
      }
    }
  }
} 
""";
      });

      return Query(
        options: QueryOptions(
          document: qry,
          variables: {
            'nRepositories': 50,
          },
          pollInterval: 10,
        ),
        builder: (QueryResult result, {VoidCallback refetch}) {
          if (result.errors != null) {
            return Text(result.errors.toString());
          }

          if (result.loading) {
            return Container(
              child: CircularProgressIndicator(),
              alignment: Alignment.center,
            );
          }

          List repositories =
              result.data['user']['starredRepositories']['edges'];

          retornaQtdTags();

          return Padding(
            padding: EdgeInsets.all(10),
            child: Card(
                color: Colors.amber.withAlpha(210),
                child: Column(
                  children: <Widget>[
                    Container(
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30.0,
                                  backgroundImage: NetworkImage(
                                      result.data['user']['avatarUrl']),
                                  backgroundColor: Colors.black38,
                                  foregroundColor: Colors.black38,
                                ),
                                subtitle: Text(result.data['user']['login']),
                                title: Text(
                                  result.data['user']['name'] != null
                                      ? result.data['user']['name']
                                      : result.data['user']['login'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ))),
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
                              alignment: Alignment.centerRight,
                              image: new AssetImage("assets/github.png")),
                        )),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: repositories.length,
                        itemBuilder: (context, index) {
                          final feedListItems = repositories[index];

                          List languages =
                              feedListItems['node']['languages']['nodes'];

                          List<Tag> _tags = [];

                          return new Card(
                              margin: const EdgeInsets.all(10.0),
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    subtitle: Text(feedListItems['node']
                                                ['description'] !=
                                            null
                                        ? feedListItems['node']['description']
                                        : 'descrição não informada'),
                                    title: new Text(
                                      feedListItems['node']['name'],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber[300],
                                        ),
                                        Text(feedListItems['node']['stargazers']
                                                ['totalCount']
                                            .toString()),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: InkWell(
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.link,
                                            color: Colors.blue[300],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 4),
                                          ),
                                          Text('link do repositorio',
                                              style: TextStyle(
                                                color: Colors.blue[300],
                                                decoration:
                                                    TextDecoration.underline,
                                              )),
                                          Spacer(),
                                          Icon(
                                            Icons.computer,
                                            color: Colors.orange[300],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 4),
                                          ),
                                          Text(
                                            feedListItems['node']
                                                        ['primaryLanguage'] !=
                                                    null
                                                ? feedListItems['node']
                                                    ['primaryLanguage']['name']
                                                : 'não informado',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange[300]),
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        if (await canLaunch(
                                            feedListItems['node']['url'])) {
                                          await launch(
                                              feedListItems['node']['url']);
                                        }
                                      },
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Center(
                                      child: Text(
                                          'ID: ' + feedListItems['node']['id']),
                                    ),
                                  ),
                                  Divider(),
                                  Container(
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text('TAGS:',
                                                textAlign: TextAlign.left),
                                          ))),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: SelectableTags(
                                      alignment: MainAxisAlignment.start,
                                      tags: _tags,
                                      columns: 3, // default 4
                                      symmetry: false, // default false
                                      onPressed: (tag) {
                                        print(tag);
                                      },
                                    ),
                                  ),
                                  Divider(),
                                  new ButtonTheme.bar(
                                    child: new ButtonBar(
                                      alignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        new RaisedButton(
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      20.0)),
                                          onPressed: () => _showDialog(
                                              feedListItems['node']['name'],
                                              languages),
                                          child: new Padding(
                                            padding: EdgeInsets.only(
                                                right: 6, left: 6),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(Icons.add,
                                                    color: Colors.white),
                                                Text(
                                                  'Adicionar TAG',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                          color: Colors.green[300],
                                        ),
                                        new RaisedButton(
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      20.0)),
                                          onPressed: () => _printLatestValue(),
                                          child: new Padding(
                                              padding: EdgeInsets.only(
                                                  right: 6, left: 6),
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(Icons.remove,
                                                      color: Colors.white),
                                                  Text(
                                                    'Remover TAG',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              )),
                                          color: Colors.red[300],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                ],
                              ));
                        },
                      ),
                    )
                  ],
                )),
          );
        },
      );
    } else
      return null;
  }
}
