import 'package:flutter/material.dart';
import 'package:floor/floor.dart';
import 'database.dart';
import 'to_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('shopping_list.db').build();
  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  MyApp(this.database);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Flutter Secure Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ListPage(database: database),
    );
  }
}

class ListPage extends StatefulWidget {
  final AppDatabase database;

  ListPage({required this.database});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<TodoItem> _items = []; // Initialize with empty list instead of late
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await widget.database.todoDao.getAllItems();
    setState(() {
      _items = items;
    });
  }

  Future<void> _addItem() async {
    final String itemName = _itemController.text.trim();
    final String quantity = _quantityController.text.trim();

    if (itemName.isNotEmpty && quantity.isNotEmpty) {
      final newItem = TodoItem(TodoItem.ID++, '$itemName (Qty: $quantity)');
      await widget.database.todoDao.insertItem(newItem);
      _itemController.clear();
      _quantityController.clear();
      _loadItems();
    }
  }

  Future<void> _removeItem(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove Item"),
        content: Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () async {
              await widget.database.todoDao.deleteItem(_items[index]);
              Navigator.pop(context);
              _loadItems();
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping List"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Add Items to Your Shopping List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _itemController,
                        decoration: InputDecoration(
                          hintText: "Enter item name",
                          labelText: "Item Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter quantity",
                          labelText: "Quantity",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addItem,
                      child: Text("Click here"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? Center(child: Text("There are no items in the list"))
                : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPress: () => _removeItem(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${index + 1}: ${_items[index].todoItem}", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}