import 'package:flutter/material.dart';
class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ListView(
        children: [
          // Welcome Banner
          Container(
            width: screenWidth * 0.9,
            height: 200,
            margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF26A69A), Color(0xFF004E89)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manager Dashboard",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Manage your venues and bookings",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.business, color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    const Text(
                      "Total Venues: 5",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Actions Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004E89),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickActionCard(
                      icon: Icons.add_business,
                      title: "Add Venue",
                      onTap: () {
                        // Navigate to add venue page
                      },
                    ),
                    _buildQuickActionCard(
                      icon: Icons.edit_location,
                      title: "Manage Venues",
                      onTap: () {
                        // Navigate to manage venues page
                      },
                    ),
                    _buildQuickActionCard(
                      icon: Icons.calendar_today,
                      title: "View Bookings",
                      onTap: () {
                        // Navigate to bookings page
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Recent Bookings Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recent Bookings",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004E89),
                  ),
                ),
                const SizedBox(height: 15),
                _buildBookingCard(
                  venueName: "Cricket Ground A",
                  customerName: "John Doe",
                  date: "Nov 12, 2025",
                  time: "10:00 AM - 12:00 PM",
                  status: "Confirmed",
                ),
                _buildBookingCard(
                  venueName: "Football Field B",
                  customerName: "Jane Smith",
                  date: "Nov 13, 2025",
                  time: "2:00 PM - 4:00 PM",
                  status: "Pending",
                ),
                _buildBookingCard(
                  venueName: "Tennis Court 1",
                  customerName: "Mike Johnson",
                  date: "Nov 14, 2025",
                  time: "6:00 PM - 8:00 PM",
                  status: "Confirmed",
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Revenue Overview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Revenue Overview",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004E89),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRevenueItem("Today", "₹2,500"),
                      _buildRevenueItem("This Week", "₹15,000"),
                      _buildRevenueItem("This Month", "₹45,000"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF26A69A).withValues(alpha: 0.3),
              offset: const Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: const Color(0xFF26A69A),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF757575),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard({
    required String venueName,
    required String customerName,
    required String date,
    required String time,
    required String status,
  }) {
    Color statusColor = status == "Confirmed" ? Colors.green : Colors.orange;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Color(0xFF26A69A),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venueName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  customerName,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "$date • $time",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String period, String amount) {
    return Column(
      children: [
        Text(
          amount,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF26A69A),
          ),
        ),
        Text(
          period,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class ManagerAnalytics extends StatefulWidget {
  const ManagerAnalytics({super.key});

  @override
  State<ManagerAnalytics> createState() => _ManagerAnalyticsState();
}

class _ManagerAnalyticsState extends State<ManagerAnalytics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Analytics Overview",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004E89),
              ),
            ),
            const SizedBox(height: 20),
            
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Total Bookings",
                    value: "156",
                    icon: Icons.calendar_month,
                    color: const Color(0xFF26A69A),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    title: "Revenue",
                    value: "₹45,000",
                    icon: Icons.attach_money,
                    color: const Color(0xFF004E89),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Active Venues",
                    value: "5",
                    icon: Icons.business,
                    color: const Color(0xFFFF7043),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    title: "Customers",
                    value: "89",
                    icon: Icons.people,
                    color: const Color(0xFFFFD54F),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Popular Venues
            const Text(
              "Popular Venues",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004E89),
              ),
            ),
            const SizedBox(height: 15),
            
            Expanded(
              child: ListView(
                children: [
                  _buildVenueAnalyticsCard("Cricket Ground A", "45 bookings", "₹15,000"),
                  _buildVenueAnalyticsCard("Football Field B", "38 bookings", "₹12,500"),
                  _buildVenueAnalyticsCard("Tennis Court 1", "32 bookings", "₹9,800"),
                  _buildVenueAnalyticsCard("Basketball Court", "25 bookings", "₹7,200"),
                  _buildVenueAnalyticsCard("Hockey Ground", "16 bookings", "₹5,500"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueAnalyticsCard(String venueName, String bookings, String revenue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.sports,
              color: Color(0xFF26A69A),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venueName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  bookings,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            revenue,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF26A69A),
            ),
          ),
        ],
      ),
    );
  }
}

class Managerhome extends StatefulWidget {
  const Managerhome({super.key});

  @override
  State<Managerhome> createState() => _ManagerhomeState();
}

class _ManagerhomeState extends State<Managerhome> {
  int index = 0;
  List<String> bottomNavItems = ["Dashboard", "Analytics"];
  List<Widget> managerPages = [
    const ManagerDashboard(),
    const ManagerAnalytics(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && index != 0) {
          setState(() {
            index = 0; // go back to Dashboard
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              // Navigate to manager profile
            },
            icon: const Icon(
              Icons.person_outline_sharp,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            bottomNavItems[index],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF26A69A),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              color: const Color(0x80374151),
              iconColor: Colors.white,
              iconSize: 24,
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    // Navigate to profile
                    break;
                  case 'settings':
                    // Navigate to settings
                    break;
                  case 'logout':
                    // Handle logout
                    Navigator.pushReplacementNamed(context, '/ManagerLogin');
                    break;
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      title: Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      leading: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      title: Text(
                        "Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      leading: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      title: Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      leading: Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: managerPages[index],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF26A69A),
          selectedItemColor: const Color(0xFFFFD54F),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          unselectedItemColor: Colors.white,
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
          currentIndex: index,
          items: const [
            BottomNavigationBarItem(
              label: "Dashboard",
              icon: Icon(Icons.dashboard),
            ),
            BottomNavigationBarItem(
              label: "Analytics",
              icon: Icon(Icons.analytics),
            ),
          ],
        ),
      ),
    );
  }
}
