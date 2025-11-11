// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'global_data.dart';

class BookingHelper {
  static void showBookingDialog(BuildContext context, Map<String, dynamic> ground) {
    List<String> payments = ["JazzCash", "EasyPaisa"];
    DateTime? selectedDate;
    String? selectedSlot;
    String? selectedPayment;
    Map<String, Map<String, List<String>>> bookedSlots = {}; // Optional: track slots

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<String> getSlots(String category) {
              if (category == "Cricket") {
                return ["9am to 2pm", "2pm to 6pm", "Full-day"];
              } else {
                List<String> slots = [];
                for (int i = 9; i < 24; i++) {
                  String start = i <= 12 ? "${i}am" : "${i - 12}pm";
                  int endHour = i + 1;
                  String end = endHour <= 12 ? "${endHour}am" : "${endHour - 12}pm";
                  if (endHour == 12) end = "12pm";
                  if (endHour == 24) end = "12am";
                  slots.add("$start-$end");
                }
                return slots;
              }
            }

            return AlertDialog(
              title: Text("Book ${ground['name']}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now().add(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            selectedSlot = null;
                          });
                        }
                      },
                      child: Text(selectedDate == null
                          ? "Select Date"
                          : "${selectedDate!.toLocal()}".split(' ')[0]),
                    ),
                    if (selectedDate != null) ...[
                      const SizedBox(height: 16),
                      const Text("Select Slot:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...getSlots(ground['category']).map((slot) {
                        String dateKey = selectedDate!.toIso8601String().split('T')[0];
                        bool isTournamentBooked = !GlobalData.isSlotAvailable(ground['name'], dateKey, slot);
                        
                        String displayText = slot;
                        bool isDisabled = false;
                        
                        if (isTournamentBooked) {
                          displayText = "$slot (Tournament)";
                          isDisabled = true;
                        }
                        
                        return ListTile(
                          leading: Radio<String>(
                            value: slot,
                            groupValue: selectedSlot,
                            onChanged: isDisabled ? null : (value) {
                              setState(() {
                                selectedSlot = value;
                              });
                            },
                          ),
                          title: Text(
                            displayText,
                            style: TextStyle(
                              color: isDisabled ? Colors.grey : Colors.black,
                            ),
                          ),
                          onTap: isDisabled ? null : () {
                            setState(() {
                              selectedSlot = slot;
                            });
                          },
                        );
                      }),
                    ],
                    const SizedBox(height: 16),
                    const Text("Select Payment Method:", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...payments.map((payment) => ListTile(
                      leading: Radio<String>(
                        value: payment,
                        groupValue: selectedPayment,
                        onChanged: (value) {
                          setState(() {
                            selectedPayment = value;
                          });
                        },
                      ),
                      title: Text(payment),
                      onTap: () {
                        setState(() {
                          selectedPayment = payment;
                        });
                      },
                    )),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedDate != null && selectedSlot != null && selectedPayment != null) {
                      GlobalData.bookedGrounds.add({
                        'ground': ground,
                        'date': selectedDate!.toLocal().toString().split(' ')[0],
                        'slot': selectedSlot,
                        'payment': selectedPayment,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Booked ${ground['name']} on ${selectedDate!.toLocal().toString().split(' ')[0]} at $selectedSlot"),
                        ),
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select date, slot, and payment")),
                      );
                    }
                  },
                  child: const Text("Confirm Booking"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
