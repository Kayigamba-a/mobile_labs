
import 'package:flutter/material.dart';

class Item {
  Item(this.name);

  final String name;
  bool bought = false;
  int quantity = 1;
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

void increaseQuantity(Item item) {
  setState(() {
    item.quantity++;
  });
}

void decreaseQuantity(Item item) {
  if (item.quantity > 1) {
    setState(() {
      item.quantity--;
    });
  }
}


@override
void dispose() {
  controller.dispose();
  super.dispose();
}




@override
Widget build(BuildContext context) {
  final itemsLeft = items.where((item) => !item.bought).length;
  final sortedItems = [
    ...items.where((item) => !item.bought),
    ...items.where((item) => item.bought),
  ];
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
              final item = sortedItems[index];
            return ListTile(
              // Mark as bought or not bought
              onTap: () {
                setState(() {
                  item.bought = !item.bought;
                });
              },

              leading: Icon(
                item.bought
                    ? Icons.check_circle
                    : Icons.shopping_basket,
                color: item.bought ? Colors.green : null,
              ),

              title: Text(
                item.name,
                style: TextStyle(
                  decoration: item.bought
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),

              // Quantity and delete controls
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Decrease quantity',
                    onPressed: () {
                      decreaseQuantity(item);
                    },
                  ),

                  Text(
                    '${item.quantity}',
                    style: const TextStyle(fontSize: 16),
                  ),

                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Increase quantity',
                    onPressed: () {
                      increaseQuantity(item);
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete item',
                    onPressed: () {
                      final removedItem = item.name;

                      setState(() {
                        items.remove(item);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$removedItem removed'),
                        ),
                      );
                    },
                  ),
                ],
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