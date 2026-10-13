
import 'package:flutter/material.dart';

class Item {
  Item(this.name);

  final String name;
  bool bought = false;
}
void main() {
  runApp(const ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.purple),
      home: const HomeScreen(title: 'My grocery List'),
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final items = [
  Item('Milk'),
  Item('Bread'),
  Item('Rice'),
  Item('Tiramisu'),
];
  final controller = TextEditingController();

  

void addItem() {
  final text = controller.text.trim();

  // Check if the input is empty
  if (text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Type an item first')),
    );
    return;
  }

  // Check if the item already exists
  if (items.any(
      (item) => item.name.toLowerCase() == text.toLowerCase(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$text is already on the list')),
      );
      return;
    }

  // Add the item and update the screen
  setState(() {
    items.add(Item(text));
  });

  // Clear the text field
  controller.clear();
}

@override
void dispose() {
  controller.dispose();
  super.dispose();
}




@override
Widget build(BuildContext context) {
  final itemsLeft = items.where((item) => !item.bought).length;
  return Scaffold(
    appBar: AppBar(
      title: Text('${widget.title} ($itemsLeft left)'),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_sweep),
          tooltip: 'Clear bought items',
          onPressed: () {
            setState(() {
              items.removeWhere((item) => item.bought);
            });
          },
        ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (value) {
                    addItem();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter an item',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: addItem,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'Your list is empty',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  setState(() {
                    items[index].bought = !items[index].bought;
                  });
                },
                leading: Icon(
                  items[index].bought
                      ? Icons.check_circle
                      : Icons.shopping_basket,
                ),
                title: Text(
                  items[index].name,
                  style: TextStyle(
                    decoration: items[index].bought
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    final removedItem = items[index].name;
                    setState(() {
                      items.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$removedItem removed'),
                      ),
                    );
                  },
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