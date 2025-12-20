import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will permanently delete all stored analytics data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        var snapshot = await FirebaseFirestore.instance.collection('classifications').get();
        Object? batchError;
        WriteBatch batch = FirebaseFirestore.instance.batch();
        int count = 0;
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
          count++;
          if (count >= 500) {
             await batch.commit();
             batch = FirebaseFirestore.instance.batch(); // Create new batch
             count = 0;
          }
        }
        if (count > 0) await batch.commit();
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared successfully')));
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error clearing data: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            tooltip: 'Clear All Data',
            onPressed: _clearData,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('classifications').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }
          
          final docs = snapshot.data?.docs ?? [];
          
          // Calculate counts
          Map<String, int> counts = {};
          for (var item in laundryItems) {
            counts[item.name] = 0;
          }

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data.containsKey('label')) {
               String label = data['label'];
               // Normalize in case names don't match exactly
               if (counts.containsKey(label)) {
                  counts[label] = (counts[label] ?? 0) + 1;
               }
            }
          }
          
          final totalCount = docs.length;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Summary Card
                   Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
                         begin: Alignment.topLeft,
                         end: Alignment.bottomRight,
                       ),
                       borderRadius: BorderRadius.circular(24),
                       boxShadow: [
                         BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                       ],
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text("Total Scans", style: TextStyle(color: Colors.white70, fontSize: 16)),
                             SizedBox(height: 8),
                             Text("Recorded", style: TextStyle(color: Colors.white, fontSize: 14)),
                           ],
                         ),
                         Text("$totalCount", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                       ],
                     ),
                   ),
                   const SizedBox(height: 32),
                   
                   // Bar Chart Section
                   Text("Frequency Distribution", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 16),
                   AspectRatio(
                     aspectRatio: 1.4,
                     child: Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                          child: BarChart(
                           BarChartData(
                             alignment: BarChartAlignment.spaceAround,
                             gridData: const FlGridData(show: false),
                             borderData: FlBorderData(show: false),
                             maxY: (counts.values.fold(0, (max, e) => e > max ? e : max)).toDouble() + 5,
                             titlesData: FlTitlesData(
                               bottomTitles: AxisTitles(
                                 sideTitles: SideTitles(
                                   showTitles: true,
                                   reservedSize: 30,
                                   getTitlesWidget: (value, meta) {
                                     int index = value.toInt();
                                     if (index >= 0 && index < laundryItems.length) {
                                       return Padding(
                                         padding: const EdgeInsets.only(top: 8.0),
                                         child: Text(
                                           laundryItems[index].name.substring(0, 2).toUpperCase(), 
                                           style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])
                                         ),
                                       );
                                     }
                                     return const SizedBox.shrink();
                                   },
                                 ),
                               ),
                               leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                               topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                               rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                             ),
                             barGroups: laundryItems.asMap().entries.map((entry) {
                               int idx = entry.key;
                               String name = entry.value.name;
                               return BarChartGroupData(
                                 x: idx,
                                 barRods: [
                                   BarChartRodData(
                                     toY: (counts[name] ?? 0).toDouble(),
                                     gradient: LinearGradient(
                                        colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                     ),
                                     width: 14,
                                     borderRadius: BorderRadius.circular(6),
                                     backDrawRodData: BackgroundBarChartRodData(
                                        show: true,
                                        toY: (counts.values.fold(0, (max, e) => e > max ? e : max)).toDouble() + 5,
                                        color: Colors.grey.shade100,
                                     )
                                   )
                                 ],
                               );
                             }).toList(),
                           ),
                         ),
                        ),
                     ),
                   ),
                   const SizedBox(height: 32),

                   // Pie Chart Section
                   Text("Market Share", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 16),
                   SizedBox(
                     height: 250,
                     child: PieChart(
                       PieChartData(
                         sectionsSpace: 4,
                         centerSpaceRadius: 50,
                         sections: laundryItems.map((item) {
                           final count = counts[item.name] ?? 0;
                           if (count == 0) return null;
                           return PieChartSectionData(
                             value: count.toDouble(),
                             title: count.toString(),
                             titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                             radius: 60,
                             color: Colors.primaries[laundryItems.indexOf(item) % Colors.primaries.length],
                             badgeWidget: Container(
                               padding: const EdgeInsets.all(4),
                               decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                               child: Text(item.name.substring(0,1), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                             ),
                             badgePositionPercentageOffset: 1.2,
                           );
                         }).whereType<PieChartSectionData>().toList(),
                       ),
                     ),
                   ),

                   const SizedBox(height: 32),
                   
                   // List View Section
                   Text("Detailed Breakdown", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 16),
                   ListView.separated(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     itemCount: laundryItems.length,
                     separatorBuilder: (c, i) => const SizedBox(height: 12),
                     itemBuilder: (context, index) {
                       final item = laundryItems[index];
                       final count = counts[item.name] ?? 0;
                       return Container(
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: Colors.grey.shade100),
                         ),
                         child: ListTile(
                           contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                           leading: Container(
                             width: 50,
                             height: 50,
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(16),
                               image: DecorationImage(
                                 image: AssetImage(item.imagePath),
                                 fit: BoxFit.cover,
                               ),
                             ),
                           ),
                           title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                           trailing: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                             decoration: BoxDecoration(
                               color: Theme.of(context).colorScheme.primaryContainer,
                               borderRadius: BorderRadius.circular(30),
                             ),
                             child: Text(
                               "$count", 
                               style: TextStyle(
                                 fontWeight: FontWeight.bold, 
                                 color: Theme.of(context).colorScheme.onPrimaryContainer
                               )
                             ),
                           ),
                         ),
                       );
                     },
                   )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
