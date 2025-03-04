import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Flutter Secure Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ListPage(),
    );
  }
}

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

//stateful widget manage shopping list
class _ListPageState extends State<ListPage> {
  final List<Map<String, dynamic>> _items = []; //list to store mapping items
  final TextEditingController _itemController = TextEditingController();//controllers to manage text input for item name and quantity
  final TextEditingController _quantityController = TextEditingController();

  void _addItem() { // function to add items
    final String itemName = _itemController.text.trim(); //get item
    final String quantity = _quantityController.text.trim(); //get quantity

    if (itemName.isNotEmpty && quantity.isNotEmpty) {
      setState(() {
        _items.add({'name': itemName, 'quantity': quantity});//add item and quantity to the list
        _itemController.clear();//clear the text fields
        _quantityController.clear();
      });
    }
  }

  void _removeItem(int index) {//function to remove an item from the list
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove Item"),
        content: Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),//close the dialog without deleting
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _items.removeAt(index);
              }); //remove the item from the list if the answer is 'YES'
              Navigator.pop(context);
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
              children: [ // section for adding items
                Text("Add Items to Your Shopping List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [//textfield for entering teh items
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
                      child: TextField(// adding quantity
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
          Expanded(//section for displaying shopping list
            child: _items.isEmpty
                ? Center(child: Text("There are no items in the list"))
                : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPress: () => _removeItem(index),//onLongPress to remove items
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${index + 1}: ${_items[index]['name']}", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(" quantity: ${_items[index]['quantity']}", style: TextStyle(color: Colors.grey[700])),
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


