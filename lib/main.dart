import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_flutter_labs/second_page.dart';
import 'package:my_flutter_labs/third_page.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/second':(context) => SecondPage(),
        '/third':(context) { return ThirdPage(); }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int numCounter = 0;
  var isChecked = false;
  final TextEditingController _num1 = TextEditingController();
  // final TextEditingController _num2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCounter();
    loadData();
  }

  /// Load the initial counter value from persistent storage on start,
  /// or fallback to 0 if it doesn't exist.
  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
    });
  }

  void loadData() {
    EncryptedSharedPreferences esp = EncryptedSharedPreferences();
    esp.getString('mydata').then((String value) {
      setState(() {
        _num1.text = value;
      }); /// Prints Hello, World!
    });
  }

  /// After a click, increment the counter state and
  /// asynchronously save it to persistent storage.
  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt('counter') ?? 0) + 1;
      prefs.setInt('counter', _counter);
    });
  }

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Text("This is the drawer section!"),
      ),
      appBar: AppBar(
        actions: [
         OutlinedButton(
          onPressed: (){
            Navigator.pushNamed(context, '/second');
    },
      child: Text("Button 1")),
        OutlinedButton(
        onPressed: (){
            Navigator.pushNamed(context, '/third');
    },
      child: Text("Button 2")),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Icon(Icons.call),
                  Text(
                    "Call".toUpperCase(),
                    style: const TextStyle(color: Colors.red),
                  )
                ],
              ),
              Column(
                children: [
                  const Icon(
                    Icons.send,
                    color: Colors.teal,
                  ),
                  Text(
                    "Route".toUpperCase(),
                    style: const TextStyle(color: Colors.red),
                  )
                ],
              ),
              Column(
                children: [
                  const Icon(
                    Icons.share,
                    color: Colors.teal,
                  ),
                  Text("Share".toUpperCase(),
                      style: const TextStyle(color: Colors.red))
                ],
              )
            ],
          ),
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Image.asset("images/ac_logo.jpg", width: 400),
              Text(
                "Algonquin College",
                style: TextStyle(fontSize: 30.0),
              )
            ],
          ),
          Text("You have pressed the button this number of times:"),
          Text("$_counter"),
          ElevatedButton(
              onPressed: _incrementCounter, child: Text("Click me!")),
          TextField(
            controller: _num1,
            decoration: InputDecoration(
                hintText: "Enter a value to be remembered",
                border: OutlineInputBorder()),
          ),
          ElevatedButton(
              onPressed: () {
                EncryptedSharedPreferences esp = EncryptedSharedPreferences();
                esp.setString('mydata', _num1.value.text).then((bool success) {
                  if (success) {
                    print('success');
                  } else {
                    print('fail');
                  }
                });
              },
              child: Text("Save"))
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Camera"),
          BottomNavigationBarItem(icon: Icon(Icons.add_call), label: "Phone")
        ],
        onTap: (btnIndex) {
          if (btnIndex == 0) {
            const snackBar = SnackBar(
              content: Text("Camera button clicked!"),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            // print("Camera button clicked");
          } else {
            const snackBar = SnackBar(
              content: Text("Phone button was clicked!"),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            // print("Phone button was clicked");
          }
        },
      ),
    );
  }
}