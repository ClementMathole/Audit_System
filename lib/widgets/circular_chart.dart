import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CircularCountChart extends StatelessWidget {
  final String collectionName; // Firestore collection
  final String label; // Text under the number
  final int total; // Max value for circle
  final List<Color> gradientColors; // Gradient colors

  const CircularCountChart({
    super.key,
    required this.collectionName,
    required this.label,
    this.total = 10,
    this.gradientColors = const [Colors.blue, Colors.lightBlueAccent],
  });

  Future<int> _getCount() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection(collectionName).get();
      return snap.size;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getCount(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            width: 30,
            height: 30,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final count = snapshot.data ?? 0;
        final cappedCount = count > total ? total : count;
        final remaining = total - cappedCount;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      centerSpaceRadius: 40,
                      sectionsSpace: 0,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: cappedCount.toDouble(),
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          title: "",
                          radius: 15,
                        ),
                        PieChartSectionData(
                          value: remaining.toDouble(),
                          color: Colors.grey.shade300,
                          title: "",
                          radius: 15,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "$count",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}
