import 'package:flutter/material.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const ProgressStepper({super.key, required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Background line connecting all steps
          Positioned(
            left: 40,
            right: 40,
            top: 20,
            child: Row(
              children: [
                Expanded(child: Container(height: 2, color: Colors.grey[300])),
                Expanded(child: Container(height: 2, color: Colors.grey[300])),
              ],
            ),
          ),
          // Active line showing progress
          Positioned(
            left: 40,
            right: 40,
            top: 20,
            child: Row(
              children: [
                Expanded(
                  child: Container(height: 2, color: currentStep > 1 ? Colors.black : Colors.transparent),
                ),
                Expanded(
                  child: Container(height: 2, color: currentStep > 2 ? Colors.black : Colors.transparent),
                ),
              ],
            ),
          ),
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final stepNumber = index + 1;
              final isActive = stepNumber <= currentStep;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.black : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$stepNumber',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.black : Colors.grey[600],
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
