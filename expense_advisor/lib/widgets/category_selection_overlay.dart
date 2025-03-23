import 'package:expense_advisor/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class CategorySelectionOverlay extends StatefulWidget {
  final String smsBody;
  final String? sender;
  final double? amount;

  const CategorySelectionOverlay({
    super.key,
    required this.smsBody,
    this.sender,
    this.amount,
  });

  @override
  State<CategorySelectionOverlay> createState() =>
      _CategorySelectionOverlayState();
}

class _CategorySelectionOverlayState extends State<CategorySelectionOverlay> {
  String? selectedCategory;

  final List<String> categories = ['Food', 'Transport', 'Shopping'];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: screenSize.width * 0.9,

          height: screenSize.height,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF3A86FF),
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
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => FlutterOverlayWindow.closeOverlay(),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.amount != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.currency_rupee,
                        size: 18,
                        color: Color(0xFF212529),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.amount!.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                    ],
                  ),
                ),

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
                          selectedColor: const Color(0xFF3A86FF),
                          backgroundColor: const Color(0xFFE9ECEF),
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

              const Spacer(),

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
                          side: const BorderSide(color: Color(0xFF6C757D)),
                        ),
                        child: const Text(
                          'Dismiss',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF495057),
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
                                  print("Sending transaction to API");
                                  await sendTransactionToAPI(
                                    100,
                                    "uncategorized",
                                    "Shopping",
                                  );

                                  FlutterOverlayWindow.closeOverlay();
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A86FF),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: const Color(0xFFADB5BD),
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
