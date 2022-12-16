import 'package:flutter/material.dart';
import 'db.dart';
import 'ClientModel.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Client>> clients;
  late String name;
  late int id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshList();
  }

  refreshList() {
    setState(() {
      clients = DBProvider.db.getAllClient();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter SQLite")),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            form(),
            list()
          ],
        ),
      )
    );
  }

  form(){
    return Form(
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextFormField(
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: (){}, child: Text("ADD")),
                ElevatedButton(onPressed: (){}, child: Text("CANCEL"))
              ],
            )
          ],
        ),
      ),
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: clients,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data!);
          }

          if (null == snapshot.data || snapshot.data?.length == 0) {
            return Text("No Data Found");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  SingleChildScrollView dataTable(List<Client> clients) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('NAME'),
          ),
          DataColumn(
            label: Text('DELETE'),
          )
        ],
        rows: clients.map((client) => DataRow(cells: [
          DataCell(
            Text('${client.id}')
          ),
          DataCell(
            Text(client.firstName),
            // onTap: () {
            //   setState(() {
            //     isUpdating = true;
            //     curUserId = employee.id;
            //   });
            //   controller.text = employee.name;
            // },
          ),
          DataCell(
            Text(client.lastName)
          )
        ])).toList(),
      ),
    );
  }
}