import 'package:expense_advisor/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class CategorySelectionOverlay extends StatefulWidget {
  final String smsBody;
  final String? sender;
  final double? amount;

  const CategorySelectionOverlay({
    Key? key,
    required this.smsBody,
    this.sender,
    this.amount,
  }) : super(key: key);

  @override
  State<CategorySelectionOverlay> createState() =>
      _CategorySelectionOverlayState();
}

class _CategorySelectionOverlayState extends State<CategorySelectionOverlay> {
  String? selectedCategory;
  // Reduced to just 6 essential categories to save space
  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to calculate overlay size
    final screenSize = MediaQuery.of(context).size;

    return Material(
      // Solid semi-transparent background color for visibility
      color: Colors.black54,
      child: Center(
        child: Container(
          width: screenSize.width * 0.9, // 90% of screen width
          // Fixed height instead of constraints to avoid overflow
          height: screenSize.height, // 40% of screen height
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Transaction',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => FlutterOverlayWindow.closeOverlay(),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount display
              if (widget.amount != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.currency_rupee, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.amount!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Category prompt
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: Text(
                  'Select a category:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),

              // Category chips - simplified grid layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children:
                      categories.map((category) {
                        final isSelected = category == selectedCategory;
                        return ChoiceChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.blue.shade600,
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedCategory = category;
                              });
                            }
                          },
                        );
                      }).toList(),
                ),
              ),

              const Spacer(), // Push buttons to the bottom
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => FlutterOverlayWindow.closeOverlay(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.blue.shade300),
                        ),
                        child: const Text(
                          'Dismiss',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            selectedCategory == null
                                ? null
                                : () async {
                                  // Optional: Implement the payment processing here
                                  // final paymentService = PaymentService();
                                  // await paymentService.processPayment(
                                  //   widget.smsBody,
                                  //   recipient: widget.sender,
                                  //   description: 'Payment categorized as $selectedCategory',
                                  //   category: selectedCategory,
                                  // );

                                  // Close the overlay after processing
                                  FlutterOverlayWindow.closeOverlay();
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Colors.blue.shade200,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
