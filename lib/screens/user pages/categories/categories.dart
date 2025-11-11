import 'package:flutter/material.dart';
import "package:f_y_p/screens/user%20pages/user%20home/favourite/global_data.dart";
import '../../../main.dart';





class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  int selectedIndex = 0;
 // List<Map<String, dynamic>> favouriteGrounds = [ ]; // push this in home page
  //List<Map<String, dynamic>> bookedGrounds = []; // New list to track booked grounds with details
  Map<String, Map<String, List<String>>> bookedSlots = {}; // groundName -> date (yyyy-MM-dd) -> list of booked slots

  List<Map<String, dynamic>> categories = [
    {
      "name": "ALL", 
      "icon": Icons.star_outline_rounded,
      "gradient": AppTheme.primaryGradient,
    },
    {
      "name": "Cricket", 
      "icon": Icons.sports_cricket_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
    },
    {
      "name": "Football", 
      "icon": Icons.sports_soccer_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
    },
    {
      "name": "Tennis", 
      "icon": Icons.sports_tennis_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
    },
    {
      "name": "Basketball", 
      "icon": Icons.sports_basketball_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFE64A19)]),
    },
    {
      "name": "Hockey", 
      "icon": Icons.sports_hockey_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)]),
    },
    {
      "name": "Volleyball", 
      "icon": Icons.sports_volleyball_outlined,
      "gradient": const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)]),
    },
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.sports_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Book ${ground['name']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientButton(
                      text: selectedDate == null ? "Select Date" : "${selectedDate!.toLocal()}".split(' ')[0],
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now().add(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: AppTheme.primaryColor,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            selectedSlot = null;
                          });
                        }
                      },
                      icon: Icons.calendar_today,
                      width: double.infinity,
                    ),
                    if (selectedDate != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        "Select Time Slot:",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      ...getSlots(ground['category']).map((slot) {
                        String dateKey = selectedDate!.toIso8601String().split('T')[0];
                        List<String> booked = bookedSlots[ground['name']]?[dateKey] ?? [];
                        bool isBooked = booked.contains(slot);
                        
                        // Check for tournament booking conflicts
                        bool isTournamentBooked = !GlobalData.isSlotAvailable(ground['name'], dateKey, slot);
                        
                        bool isDisabled = false;
                        String displayText = slot;
                        
                        if (ground['category'] == "Cricket") {
                          if (slot == "Full-day") {
                            isDisabled = booked.contains("9am to 2pm") || booked.contains("2pm to 6pm") || 
                                        !GlobalData.isSlotAvailable(ground['name'], dateKey, "9am to 2pm") ||
                                        !GlobalData.isSlotAvailable(ground['name'], dateKey, "2pm to 6pm");
                          } else {
                            isDisabled = booked.contains("Full-day") || 
                                        !GlobalData.isSlotAvailable(ground['name'], dateKey, "Full-day");
                          }
                        }
                        
                        if (isBooked) {
                          displayText = "$slot (Booked)";
                        } else if (isTournamentBooked) {
                          displayText = "$slot (Tournament)";
                          isDisabled = true;
                        } else if (isDisabled) {
                          displayText = "$slot (Unavailable)";
                        }
                        
                        return ListTile(
                          leading: Radio<String>(
                            value: slot,
                            groupValue: selectedSlot,
                            onChanged: (isBooked || isDisabled || isTournamentBooked) ? null : (value) {
                              setState(() {
                                selectedSlot = value;
                              });
                            },
                          ),
                          title: Text(
                            displayText,
                            style: TextStyle(
                              color: (isBooked || isDisabled || isTournamentBooked) ? Colors.grey : null,
                            ),
                          ),
                          onTap: (isBooked || isDisabled || isTournamentBooked) ? null : () {
                            setState(() {
                              selectedSlot = slot;
                            });
                          },
                        );
                      }),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      "Select Payment Method:",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        text: "Confirm",
                        onPressed: () {
                          if (selectedDate != null && selectedSlot != null && selectedPayment != null) {
                            // Mark slot as booked
                            String dateKey = selectedDate!.toIso8601String().split('T')[0];
                            bookedSlots.putIfAbsent(ground['name'], () => {});
                            bookedSlots[ground['name']]!.putIfAbsent(dateKey, () => []);
                            bookedSlots[ground['name']]![dateKey]!.add(selectedSlot!);
                            
                            // Add to bookedGrounds list with date
                            GlobalData.bookedGrounds.add({
                              'ground': ground,
                              'date': selectedDate!.toLocal().toString().split(' ')[0],
                              'slot': selectedSlot,
                              'payment': selectedPayment,
                            });

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Booking confirmed for ${ground['name']} on ${selectedDate!.toLocal().toString().split(' ')[0]} at $selectedSlot",
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppTheme.successColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Please select a date, slot, and payment method"),
                                  ],
                                ),
                                backgroundColor: AppTheme.warningColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icons.check,
                        height: 44,
                      ),
                    ),
                  ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    String selectedCategory = categories[selectedIndex]['name'];

    List<Map<String, dynamic>> filteredSports = selectedCategory == "ALL"
        ? sports
        : sports.where((item) => item['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: ModernAppBar(
        title: "Book Your Venues",
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: GroundSearchDelegate(sports: sports),
                );
              },
              icon: const Icon(Icons.search_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Category Selector
            Container(
              height: 120,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: isSelected ? category['gradient'] : null,
                              color: isSelected ? null : colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected 
                                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                                    : Colors.black.withValues(alpha: 0.1),
                                  blurRadius: isSelected ? 8 : 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              category['icon'],
                              color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['name'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔹 Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "${categories[selectedIndex]['name']} Venues",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${filteredSports.length} available",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
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
                final isFavourite = GlobalData.favouriteGrounds.contains(ground);

                return ModernCard(
                  margin: const EdgeInsets.all(6),
                  padding: EdgeInsets.zero,
                  color: colorScheme.surface,
                  elevation: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: 140,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image(
                                image: ground['image'],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Gradient overlay for better text visibility
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isFavourite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavourite ? Colors.red : Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isFavourite) {
                                        GlobalData.favouriteGrounds.remove(ground);
                                      } else {
                                        GlobalData.favouriteGrounds.add(ground);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            // Category badge
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ground['category'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ground['name'],
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GradientButton(
                                text: "Book Now",
                                onPressed: () => _showBookingDialog(ground),
                                gradient: AppTheme.secondaryGradient,
                                height: 36,
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
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

// Search Delegate for Ground Search
class GroundSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final List<Map<String, dynamic>> sports;

  GroundSearchDelegate({required this.sports});

  @override
  String get searchFieldLabel => 'Search venues...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredSports = sports.where((ground) {
      return ground['name'].toLowerCase().contains(query.toLowerCase()) ||
             ground['category'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filteredSports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No venues found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredSports.length,
      itemBuilder: (context, index) {
        final ground = filteredSports[index];
        final isFavourite = GlobalData.favouriteGrounds.contains(ground);

        return ModernCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: ground['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              ground['name'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(ground['category']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: isFavourite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    if (isFavourite) {
                      GlobalData.favouriteGrounds.remove(ground);
                    } else {
                      GlobalData.favouriteGrounds.add(ground);
                    }
                  },
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              close(context, ground);
              // You can add navigation to booking dialog here if needed
            },
          ),
        );
      },
    );
  }
}