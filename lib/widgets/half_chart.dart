import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OverallHalfCircleChart extends StatelessWidget {
  final List<String> collections; // All collections to sum
  final List<List<Color>> gradientColors; // Colors for each collection
  final String subLabel; // small description below total

  const OverallHalfCircleChart({
    super.key,
    required this.collections,
    required this.gradientColors,
    this.subLabel = "Total Achievements",
  });

  Future<int> _getTotalCount() async {
    int total = 0;
    for (var i = 0; i < collections.length; i++) {
      try {
        final snap =
            await FirebaseFirestore.instance.collection(collections[i]).get();
        total += snap.size;
      } catch (e) {
        continue; // ignore missing collection
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getTotalCount(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            width: 300,
            height: 150,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          );
        }

        final totalCount = snapshot.data ?? 0;
        final totalSections = collections.length;

        // Split total equally across sections for gradient colors
        final sectionValue = totalCount / totalSections;

        return SizedBox(
          width: double.infinity,
          height: 150, // bigger width & height
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: 180, // half circle
                  sectionsSpace: 0,
                  centerSpaceRadius: 50,
                  sections: [
                    for (var i = 0; i < totalSections; i++)
                      PieChartSectionData(
                        value: sectionValue.toDouble(),
                        gradient: LinearGradient(
                          colors: gradientColors[i],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        radius: 25,
                        title: "",
                      ),
                    // Invisible bottom half
                    PieChartSectionData(
                      value: totalCount.toDouble(),
                      color: Colors.transparent,
                      radius: 25,
                      title: "",
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$totalCount",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
