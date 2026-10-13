
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

  // PART 3: Add a new item or increase an existing quantity
  void addItem() {
    final text = controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type an item first')),
      );
      return;
    }

    final matches = items.where(
      (item) =>
          item.name.toLowerCase() == text.toLowerCase(),
    );

    if (matches.isNotEmpty) {
      final existingItem = matches.first;

      setState(() {
        existingItem.quantity++;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${existingItem.name} is already on the list: now ×${existingItem.quantity}',
          ),
        ),
      );

      controller.clear();
      return;
    }

    setState(() {
      items.add(Item(text));
    });

    controller.clear();
  }

  // PART 4: Delete an item with Undo
  void deleteItem(Item item) {
    // Remember the original position
    final originalIndex = items.indexOf(item);

    if (originalIndex == -1) return;

    // Remove the item
    setState(() {
      items.remove(item);
    });

    final messenger = ScaffoldMessenger.of(context);

    // Prevent old messages from queuing
    messenger.hideCurrentSnackBar();

    // Show the deleted item with an Undo button
    messenger.showSnackBar(
      SnackBar(
        content: Text('${item.name} removed'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Prevent accidentally restoring the same item twice
            if (items.contains(item)) return;

            setState(() {
              // Keep the index within the current list size
              final position = originalIndex.clamp(0, items.length);

              // Restore the same Item object
              items.insert(position, item);
            });
          },
        ),
      ),
    );
  }

  // Mark or unmark an item as bought
  void toggleBought(Item item) {
    setState(() {
      item.bought = !item.bought;
    });
  }

  // Increase quantity
  void increaseQuantity(Item item) {
    setState(() {
      item.quantity++;
    });
  }

  // Decrease quantity, minimum is 1
  void decreaseQuantity(Item item) {
    if (item.quantity > 1) {
      setState(() {
        item.quantity--;
      });
    }
  }

  // Remove all bought items
  void clearBoughtItems() {
    setState(() {
      items.removeWhere((item) => item.bought);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsLeft =
        items.where((item) => !item.bought).length;

    // Show unbought items first, bought items at the bottom
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
            onPressed: clearBoughtItems,
          ),
        ],
      ),

      body: Column(
        children: [
          // Input field and Add button
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
                    itemCount: sortedItems.length,
                    itemBuilder: (context, index) {
                      // Use the actual item, not its displayed index
                      final item = sortedItems[index];

                      return ListTile(
                        onTap: () {
                          toggleBought(item);
                        },

                        leading: Icon(
                          item.bought
                              ? Icons.check_circle
                              : Icons.shopping_basket,
                          color: item.bought
                              ? Colors.green
                              : null,
                        ),

                        title: Text(
                          item.name,
                          style: TextStyle(
                            decoration: item.bought
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),

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
                                deleteItem(item);
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
