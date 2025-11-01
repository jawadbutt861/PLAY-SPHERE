import 'dart:async';
import 'package:flutter/material.dart';

class AutoScrollingImageRow extends StatefulWidget {
  final String category;
  final List<String> imageAssets;

  const AutoScrollingImageRow({
    Key? key,
    required this.category,
    required this.imageAssets,
  }) : super(key: key);

  @override
  State<AutoScrollingImageRow> createState() => _AutoScrollingImageRowState();
}

class _AutoScrollingImageRowState extends State<AutoScrollingImageRow> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= widget.imageAssets.length) {
          nextPage = 0; // Loop back to start
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 380.0,
          height: 200.0, // Adjust height as needed
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageAssets.length,
            itemBuilder: (context, index) {
              return _buildStyledImage(widget.imageAssets[index]);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageAssets.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 8.0,
              width: _currentPage == index ? 24.0 : 8.0,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledImage(String asset) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Define categories and their image assets (5 images each)
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Top Cricket Grounds',
      'images': [
        'assets/images/c1.jpeg',
        'assets/images/c1.jpeg',
        'assets/images/c1.jpeg',
        'assets/images/c1.jpeg',
        
      ],
    },
    {
      'name': 'Top Football Grounds',
      'images': [
        'assets/images/f1.jpg',
        'assets/images/f1.jpg',
        'assets/images/f1.jpg',
        'assets/images/f1.jpg',
        
      ],
    },
    {
      'name': 'Top Tennis Courts',
      'images': [
        'assets/images/t1.jpeg',
        'assets/images/t1.jpeg',
        'assets/images/t1.jpeg',
        'assets/images/t1.jpeg',
        
      ],
    },
    {
      'name': 'Top Basketball Courts',
      'images': [
        'assets/images/b1.webp',
        'assets/images/b1.webp',
        'assets/images/b1.webp',
        'assets/images/b1.webp',
        
      ],
    },
    {
      'name': 'Top Hockey Grounds',
      'images': [
        'assets/images/h1.webp',
        'assets/images/h1.webp',
        'assets/images/h1.webp',
        'assets/images/h1.webp',
        'assets/images/h1.webp',
      ],
    },
    {
      'name': 'Top Volleyball Courts',
      'images': [
        'assets/images/v1.jpg',
        'assets/images/v1.jpg',
        'assets/images/v1.jpg',
        'assets/images/v1.jpg',
        
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ListView(
        children: [
          Container(
            width: screenWidth * 0.9, // Responsive width
            height: 300,
            margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/bg2.jpg'),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.5, 40), // Responsive button size
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/Categories');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Book Venue",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_outward_outlined,
                        color: Color(0xFF757575),
                        size: 25,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/Calender');
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0xFF004E89),
                          offset: Offset(2, 1),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 30,
                        ),
                        Text(
                          "My Calender",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/Favourite');
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.3),
                          offset: const Offset(2, 1),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          size: 30,
                        ),
                        Text(
                          "Favourite Venue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/BookingHistory');
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.3),
                          offset: const Offset(2, 1),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 30,
                        ),
                        Text(
                          "Booking History",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Add scrolling rows for each category
          ...categories.map((category) => Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 25.0, bottom: 10.0),
                  child: Text(
                    category['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              AutoScrollingImageRow(
                category: category['name'],
                imageAssets: List<String>.from(category['images']),
              ),
            ],
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}