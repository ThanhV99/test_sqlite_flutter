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
        useMaterial3: true
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  late Future<List<Client>> clients;
  String? first_name;
  String? last_name;
  bool blocked = false;
  bool checkbox_value = false;
  late int curUserId;
  late bool isUpdating;
  TextEditingController controller_firstName = TextEditingController();
  TextEditingController controller_lastName = TextEditingController();
  final formKey = GlobalKey<FormState>();

  refreshList() {
    setState(() {
      clients = DBProvider.db.getAllClient();
    });
  }

  clearForm(){
    controller_lastName.text = "";
    controller_firstName.text = "";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshList();
    WidgetsBinding.instance.addObserver(this);
    isUpdating = false;
    print("init state");
  }

  @override
  void dispose(){
    super.dispose();
    WidgetsBinding.instance.addObserver(this);
    refreshList();
    print("dispose state");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("Flutter SQLite")),
      body: Container(
        // height: size.height,
        child: Column(
          children: [
            form(),
            list(),
          ],
        ),
      )
    );
  }

  form(){
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller_firstName,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                hintText: "First Name"
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (text){
                if (text?.length == null || text?.length == 0){
                  return "valid";
                }
                return null;
              },
              onSaved: (value){
                first_name = value;
              },
            ),
            const SizedBox(height: 10,),
            TextFormField(
              controller: controller_lastName,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  hintText: "Last Name"
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (text){
                if (text?.length == null || text?.length == 0){
                  return "valid";
                }
                return null;
              },
              onSaved: (value){
                last_name = value;
              },
            ),
            const SizedBox(height: 10,),
            CheckboxListTile(
              value: checkbox_value,
              title: Text("BLOCKED"),
              onChanged: (value){
                setState(() {
                  checkbox_value = value!;
                });
              },
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: (){
                    if (formKey.currentState!.validate()){
                      formKey.currentState!.save();
                      print(first_name);
                      print(last_name);
                      if (isUpdating){
                        Client c = Client(firstName: first_name!, lastName: last_name!, blocked: checkbox_value);
                        DBProvider.db.updateClient(c);
                        setState(() {
                          isUpdating = false;
                        });
                      } else {
                        Client c = Client(firstName: first_name!, lastName: last_name!, blocked: checkbox_value);
                        DBProvider.db.insertClient(c);
                      }
                    }
                    clearForm();
                    refreshList();
                  },
                  child: Text( isUpdating ? "UPDATE" : "ADD")),
                ElevatedButton(
                  onPressed: (){
                    setState(() {
                      isUpdating = false;
                    });
                    clearForm();
                  },
                  child: const Text("CANCEL"))
              ],
            )
          ],
        ),
      ),
    );
  }

  list() {
    return FutureBuilder(
      future: clients,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return dataTable(snapshot.data!);
        } else if (null == snapshot.data || snapshot.data!.length == 0) {
          return const Text("No Data Found");
        }
        return const CircularProgressIndicator();
      },
    );
  }

  dataTable(List<Client> clients) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("DATA"),
        Flexible(
          child: ListView.builder(
            // scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: clients.length,
            itemBuilder: (context, index){
              return Card(
                child: InkWell(
                  onTap: (){
                    setState(() {
                      isUpdating = true;
                      curUserId = clients[index].id!;
                    });
                    controller_firstName.text = clients[index].firstName;
                    controller_lastName.text = clients[index].lastName;
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("id: ${clients[index].id}"),
                      Flexible(
                        child: Column(
                          children: [
                            Text("first name: ${clients[index].firstName}"),
                            Text("last name: ${clients[index].lastName}")
                          ],
                        ),
                      ),
                      Text("Blocked: ${clients[index].blocked}"),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: (){
                          DBProvider.db.deleteClientID(clients[index].id!);
                          refreshList();
                        },
                      )
                    ],
                  )
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}