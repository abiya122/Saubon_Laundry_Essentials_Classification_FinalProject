import 'package:flutter/material.dart';
import 'data.dart';
import 'detail_screen.dart';
import 'classification_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry Essentials'),
        actions: [
          IconButton(
            tooltip: 'Analytics',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Explore Laundry Items",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75, // Adjust height
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: laundryItems.length,
                itemBuilder: (context, index) {
                  final item = laundryItems[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(item: item))),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.asset(item.imagePath, fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassificationScreen())),
        label: const Text('Scan / Classify'),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}
