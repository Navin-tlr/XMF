import 'package:flutter/material.dart';
import 'package:smart_calorie_flutter/services/tdee_service.dart';

class StrategyScreen extends StatefulWidget {
  const StrategyScreen({super.key});

  @override
  State<StrategyScreen> createState() => _StrategyScreenState();
}

class _StrategyScreenState extends State<StrategyScreen> {
  bool _isLoading = false;
  AlgorithmOutput? _output;
  String? _errorMessage;

  // This function calls the algorithm and updates the UI with the result
  Future<void> _runCheckIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _output = null;
    });

    try {
      final result = await AdaptiveAlgorithm.runWeeklyUpdate();
      setState(() {
        _output = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Check-In'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _buildContentView(),
      ),
    );
  }

  // Helper method to decide what to show on the screen
  Widget _buildContentView() {
    if (_errorMessage != null) {
      // If there was an error, show it
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage', style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _runCheckIn, child: const Text('Try Again')),
          ],
        ),
      );
    }

    if (_output != null) {
      // If we have results, display them
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _ResultCard(title: 'Estimated TDEE', value: '${_output!.estimatedTdee.toStringAsFixed(0)} kcal'),
          _ResultCard(title: 'Weight Trend', value: '${_output!.weightTrendPerWeek.toStringAsFixed(2)} kg/week'),
          _ResultCard(title: 'New Calorie Target', value: '${_output!.newCalorieTarget.toStringAsFixed(0)} kcal', isHighlighted: true),
          Card(
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Reasoning: ${_output!.adjustmentReasoning}', style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(onPressed: _runCheckIn, child: const Text('Recalculate')),
        ],
      );
    }

    // By default, show the button to start the check-in
    return ElevatedButton(
      onPressed: _runCheckIn,
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
      child: const Text('Perform Weekly Check-In', style: TextStyle(fontSize: 16)),
    );
  }
}

// A reusable card for displaying results
class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isHighlighted;

  const _ResultCard({required this.title, required this.value, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isHighlighted ? Colors.greenAccent.withOpacity(0.2) : Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}