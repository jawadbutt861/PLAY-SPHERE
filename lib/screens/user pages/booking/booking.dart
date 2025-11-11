import 'package:flutter/material.dart';
import "package:f_y_p/screens/user%20pages/user%20home/favourite/global_data.dart";

class Booked extends StatefulWidget {
  const Booked({super.key});

  @override
  State<Booked> createState() => _BookedState();
}

class _BookedState extends State<Booked> {
  @override
  Widget build(BuildContext context) {
    final bookings = GlobalData.bookedGrounds;

    return Scaffold(
      
      body: bookings.isEmpty
          ? const Center(
        child: Text(
          "No booked venues yet 😢",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final ground = booking['ground'];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
              subtitle: Text(
                  "Date: ${booking['date']}\nSlot: ${booking['slot']}\nPayment: ${booking['payment']}"),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  setState(() {
                    GlobalData.bookedGrounds.remove(booking);
                    // Remove from booked grounds
                    GlobalData.bookedGrounds.removeWhere((b) => b == booking);
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
