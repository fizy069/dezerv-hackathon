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
  final List<String> categories = ['Food', 'Transport', 'Shopping'];

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to calculate overlay size
    final screenSize = MediaQuery.of(context).size;

    return Material(
      // Darker semi-transparent background for better contrast
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: screenSize.width * 0.9, // 90% of screen width
          // Fixed height instead of constraints to avoid overflow
          height: screenSize.height, // 40% of screen height
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA), // Slightly off-white background
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 3),
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
                decoration: const BoxDecoration(
                  color: Color(0xFF3A86FF), // Vibrant blue header
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New Transaction',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text for contrast
                      ),
                    ),
                    GestureDetector(
                      onTap: () => FlutterOverlayWindow.closeOverlay(),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white, // White icon for contrast
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
                      const Icon(
                        Icons.currency_rupee,
                        size: 18,
                        color: Color(0xFF212529), // Dark gray icon
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.amount!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529), // Dark gray text
                        ),
                      ),
                    ],
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
                              color:
                                  isSelected
                                      ? Colors.white
                                      : const Color(0xFF495057),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(
                            0xFF3A86FF,
                          ), // Match header color
                          backgroundColor: const Color(
                            0xFFE9ECEF,
                          ), // Light gray background
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
                          side: const BorderSide(
                            color: Color(0xFF6C757D),
                          ), // Medium gray border
                        ),
                        child: const Text(
                          'Dismiss',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF495057), // Dark gray text
                          ),
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
                          backgroundColor: const Color(
                            0xFF3A86FF,
                          ), // Match header color
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: const Color(
                            0xFFADB5BD,
                          ), // Light gray when disabled
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
