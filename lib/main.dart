import 'package:flutter/material.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'Shopping List',
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
  late List<TodoItem> _items = [];
  TodoItem? _selectedItem;
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

  Future<void> _deleteItem(TodoItem item) async {
    await widget.database.todoDao.deleteItem(item);
    setState(() {
      _selectedItem = null;
    });
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            title: Text("Shopping List"),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          body: isWideScreen
              ? Row(
            children: [
              Expanded(child: _buildItemList()),
              VerticalDivider(),
              Expanded(
                child: _selectedItem != null
                    ? DetailsPage(
                  item: _selectedItem!,
                  onDelete: _deleteItem,
                  onClose: () => setState(() => _selectedItem = null),
                )
                    : Center(child: Text("Select an item to view details")),
              ),
            ],
          )
              : Column(
            children: [
              Expanded(flex: 2, child: _buildItemList()), // List at the top
              Divider(),
              Expanded(
                flex: 3,
                child: _selectedItem != null
                    ? DetailsPage(
                  item: _selectedItem!,
                  onDelete: _deleteItem,
                  onClose: () => setState(() => _selectedItem = null),
                )
                    : Center(child: Text("Select an item to view details")),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
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
                child: Text("Add"),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_items[index].todoItem),
                onTap: () => setState(() => _selectedItem = _items[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DetailsPage extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onClose;
  final Function(TodoItem) onDelete;

  DetailsPage({required this.item, required this.onDelete, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Item: ${item.todoItem}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Quantity: ${_extractQuantity(item.todoItem)}", style: TextStyle(fontSize: 18)),
          Text("Database ID: ${item.id}", style: TextStyle(fontSize: 16)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => onDelete(item),
                child: Text("Delete"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: onClose,
                child: Text("Close"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Extract quantity from item.todoItem (formatted as "Item (Qty: X)")
  String _extractQuantity(String itemText) {
    final match = RegExp(r'\(Qty: (\d+)\)').firstMatch(itemText);
    return match != null ? match.group(1)! : "Unknown";
  }
}

