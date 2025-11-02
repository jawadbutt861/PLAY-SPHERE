import 'package:flutter/material.dart';
import 'global_data.dart';
import 'booking_helper.dart';

class Favourite extends StatefulWidget {
  const Favourite({super.key});

  @override
  State<Favourite> createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  @override
  Widget build(BuildContext context) {
    final favourites = GlobalData.favouriteGrounds;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favourite Venues",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A659E),
      ),
      body: favourites.isEmpty
          ? const Center(child: Text("No favourite venues yet 😢"))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: favourites.length,
        itemBuilder: (context, index) {
          final ground = favourites[index];

          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: ground['image'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                ground['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      BookingHelper.showBookingDialog(context, ground);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A),
                    ),
                    child: const Text("Book Now"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        GlobalData.favouriteGrounds.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "${ground['name']} removed from favourites"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Remove"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
