import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  int selectedIndex = 0;
  List<Map<String, dynamic>> favouriteGrounds = []; // push this in home page
  List<Map<String, dynamic>> bookedGrounds = []; // New list to track booked grounds with details
  Map<String, Map<String, List<String>>> bookedSlots = {}; // groundName -> date (yyyy-MM-dd) -> list of booked slots

  List<Map<String, dynamic>> categories = [
    {"name": "ALL", "icon": Icon(Icons.star_outline_outlined, size: 30, color: Colors.black)},
    {"name": "Cricket", "icon": Icon(Icons.sports_cricket_outlined, size: 30, color: Colors.black)},
    {"name": "Football", "icon": Icon(Icons.sports_soccer_outlined, size: 30, color: Colors.black)},
    {"name": "Tennis", "icon": Icon(Icons.sports_tennis_outlined, size: 30, color: Colors.black)},
    {"name": "Basketball", "icon": Icon(Icons.sports_basketball_outlined, size: 30, color: Colors.black)},
    {"name": "Hockey", "icon": Icon(Icons.sports_hockey_outlined, size: 30, color: Colors.black)},
    {"name": "Volleyball", "icon": Icon(Icons.sports_volleyball_outlined, size: 30, color: Colors.black)},
  ];

  // 🏏 Full list of grounds (4 per category)
  List<Map<String, dynamic>> sports = [
    // Cricket
    {'image': AssetImage('assets/images/c1.jpeg'), 'category': "Cricket", 'name': "Buitems Cricket Ground "},
    {'image': AssetImage('assets/images/c1.jpeg'), 'category': "Cricket", 'name': "Shola Cricket Ground "},
    {'image': AssetImage('assets/images/c1.jpeg'), 'category': "Cricket", 'name': "Haideri Cricket Ground "},
    {'image': AssetImage('assets/images/c1.jpeg'), 'category': "Cricket", 'name': "Bolan Cricket Ground "},

    // Football
    {'image': AssetImage('assets/images/f1.jpg'), 'category': "Football", 'name': "Buitems Football Ground "},
    {'image': AssetImage('assets/images/f1.jpg'), 'category': "Football", 'name': "Shahbaz Football Ground "},
    {'image': AssetImage('assets/images/f1.jpg'), 'category': "Football", 'name': "Railway Football Ground "},
    {'image': AssetImage('assets/images/f1.jpg'), 'category': "Football", 'name': "Spini Football Ground "},

    // Tennis
    {'image': AssetImage('assets/images/t1.jpeg'), 'category': "Tennis", 'name': "Buitems Tennis Court "},
    {'image': AssetImage('assets/images/t1.jpeg'), 'category': "Tennis", 'name': "UoB Tennis Court "},
    {'image': AssetImage('assets/images/t1.jpeg'), 'category': "Tennis", 'name': "Alhamd Tennis Court "},
    {'image': AssetImage('assets/images/t1.jpeg'), 'category': "Tennis", 'name': "NUML Court "},

    // Basketball
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "Buitems Basketball Court "},
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "UoB Basketball Court "},
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "Alhamd Basketball Court "},
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "NUML Basketball Court "},

    // Hockey
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "Ayub Hockey Ground "},
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "Buitems Hockey Ground "},
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "UoB Hockey Ground "},
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "NUML Hockey Ground "},

    // Volleyball
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "Buitems Volleyball Court "},
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "Ayub Volleyball Court "},
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "Alhamd Volleyball Court "},
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "UoB Volleyball Court "},
  ];

  List<String> getSlots(String category) {
    if (category == "Cricket") {
      return ["9am to 2pm", "2pm to 6pm", "Full-day"];
    } else {
      List<String> slots = [];
      for (int i = 9; i < 24; i++) { // 9am to 11pm
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

  void _showBookingDialog(Map<String, dynamic> ground) {
    List<String> payments = ["JazzCash", "EasyPaisa"];
    DateTime? selectedDate;
    String? selectedSlot;
    String? selectedPayment;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Book ${ground['name']}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            selectedSlot = null; // Reset slot when date changes
                          });
                        }
                      },
                      child: Text(selectedDate == null ? "Select Date" : "${selectedDate!.toLocal()}".split(' ')[0]),
                    ),
                    if (selectedDate != null) ...[
                      const SizedBox(height: 16),
                      const Text("Select Slot:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...getSlots(ground['category']).map((slot) {
                        String dateKey = selectedDate!.toIso8601String().split('T')[0];
                        List<String> booked = bookedSlots[ground['name']]?[dateKey] ?? [];
                        bool isBooked = booked.contains(slot);
                        bool isDisabled = false;
                        if (ground['category'] == "Cricket") {
                          if (slot == "Full-day") {
                            isDisabled = booked.contains("9am to 2pm") || booked.contains("2pm to 6pm");
                          } else {
                            isDisabled = booked.contains("Full-day");
                          }
                        }
                        return RadioListTile<String>(
                          title: Text(isBooked ? "$slot (Booked)" : slot),
                          value: slot,
                          groupValue: selectedSlot,
                          onChanged: (isBooked || isDisabled) ? null : (value) {
                            setState(() {
                              selectedSlot = value;
                            });
                          },
                        );
                      }),
                    ],
                    const SizedBox(height: 16),
                    const Text("Select Payment Method:", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...payments.map((payment) => RadioListTile<String>(
                      title: Text(payment),
                      value: payment,
                      groupValue: selectedPayment,
                      onChanged: (value) {
                        setState(() {
                          selectedPayment = value;
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
                      // Mark slot as booked
                      String dateKey = selectedDate!.toIso8601String().split('T')[0];
                      bookedSlots.putIfAbsent(ground['name'], () => {});
                      bookedSlots[ground['name']]!.putIfAbsent(dateKey, () => []);
                      bookedSlots[ground['name']]![dateKey]!.add(selectedSlot!);
                      
                      // Add to bookedGrounds list with date
                      bookedGrounds.add({
                        'ground': ground,
                        'date': selectedDate!.toLocal().toString().split(' ')[0], // Date as string
                        'slot': selectedSlot,
                        'payment': selectedPayment,
                      });
                      
                      // Handle booking logic here (e.g., save to database, show success message)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Booking confirmed for ${ground['name']} on ${selectedDate!.toLocal().toString().split(' ')[0]} at $selectedSlot via $selectedPayment")),
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a date, slot, and payment method")),
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

  @override
  Widget build(BuildContext context) {
    String selectedCategory = categories[selectedIndex]['name'];

    List<Map<String, dynamic>> filteredSports = selectedCategory == "ALL"
        ? sports
        : sports.where((item) => item['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Book Your Venues",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A659E),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Category Selector
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(2, 0),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: isSelected ? const Color(0xFFFF7043) : Colors.white,
                            radius: 30,
                            child: category['icon'],
                          ),
                        ),
                        Text(
                          category['name'],
                          style: const TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 🔹 Section Title (Left-aligned)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Text(
                "${categories[selectedIndex]['name']} ",
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 🔹 Grid of Filtered Grounds
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, // Responsive: adjusts columns based on screen width
                mainAxisExtent: 270, // Fixed height for each card to ensure content fits
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredSports.length,
              itemBuilder: (context, index) {
                final ground = filteredSports[index];
                final isFavourite = favouriteGrounds.contains(ground);

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
                    ],
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max, // Ensures column fills the entire card height
                    children: [
                      SizedBox(
                        height: 150, // Fixed height for image to maintain aspect
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image(
                                image: ground['image'],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: IconButton(
                                icon: Icon(
                                  isFavourite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavourite ? Colors.red :  Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (isFavourite) {
                                      favouriteGrounds.remove(ground);
                                    } else {
                                      favouriteGrounds.add(ground);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded( // Fills the remaining height of the card
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ground['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _showBookingDialog(ground),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF26A69A),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 36),
                                ),
                                child: const Text("Book Now"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
          ],
        ),
      ),
      
    );
  }
}