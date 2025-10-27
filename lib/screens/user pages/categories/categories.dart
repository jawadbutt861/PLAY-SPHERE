import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  int selectedIndex = 0;
   List<Map<String, dynamic>> favouriteGrounds = [];
 

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
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "Buitems Basketball Ground "},
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "UoB Basketball Ground "},
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "Alhamd Basketball Ground "},
    {'image': AssetImage('assets/images/b1.webp'), 'category': "Basketball", 'name': "NUML Basketball Ground "},

    // Hockey
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "Ayub Hockey Ground "},
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "Buitems Hockey Ground "},
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "UoB Hockey Ground "},
    {'image': AssetImage('assets/images/h1.webp'), 'category': "Hockey", 'name': "NUML Hockey Ground "},

    // Volleyball
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "Buitems Volleyball Ground "},
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "Ayub Volleyball Ground "},
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "Alhamd Volleyball Ground "},
    {'image': AssetImage('assets/images/v1.jpg'), 'category': "Volleyball", 'name': "UoB Volleyball Ground "},
  ];

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
        backgroundColor: const Color(0xFF26A69A),

        actions: [
          IconButton(
            onPressed: (){

          }, 
          icon: Icon(Icons.search,color: Colors.black,)),
          
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // ✅ Text aligned left
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
                            backgroundColor:
                                isSelected ? const Color(0xFFFF7043) : Colors.white,
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
                "${categories[selectedIndex]['name']} Grounds",
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 🔹 Grid of Filtered Grounds
            GridView.builder(
              
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cards per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
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
                    
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image(
                          image: ground['image'],
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                     
                      const SizedBox(height: 8),
                      Text(
                        ground['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                       Positioned(
                            right: 8,
                            top: 8,
                            child: IconButton(
                              icon: Icon(
                                isFavourite ? Icons.favorite : Icons.favorite_border,
                                color: isFavourite ? Colors.red : Color(0xFF757575),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
