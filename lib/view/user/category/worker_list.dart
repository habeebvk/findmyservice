import 'package:findmyservicesapp/view/user/category/workers_details_page.dart';
import 'package:flutter/material.dart';

class ServiceList extends StatelessWidget {
  final String? role;
  const ServiceList({super.key, this.role});

  final services = const [
    {
      "subtitle": "Darrell Steward",
      "price": "₹60",
      "rating": "4.8",
      "icon": Icons.electrical_services,
      "role": "electrician",
    },
    {
      "subtitle": "Ronald Richards",
      "price": "₹53",
      "rating": "4.9",
      "icon": Icons.plumbing,
      "role": "plumber",
    },
    {
      "subtitle": "Jimmy Hadson",
      "price": "₹45",
      "rating": "4.8",
      "icon": Icons.handyman,
      "role": "carpenter",
    },
    {
      "subtitle": "Devon Lane",
      "price": "₹78",
      "rating": "5.0",
      "icon": Icons.ac_unit,
      "role": "mechanic",
    },
    {
      "subtitle": "Jenny Wilson",
      "price": "₹45",
      "rating": "4.7",
      "icon": Icons.cleaning_services,
      "role": "cleaner",
    },
    {
      "subtitle": "Alen Walker",
      "price": "₹55",
      "rating": "4.6",
      "icon": Icons.format_paint,
      "role": "painter",
    },
    {
      "subtitle": "Robert Fox",
      "price": "₹65",
      "rating": "4.4",
      "icon": Icons.handyman,
      "role": "welder",
    },
    {
      "subtitle": "Courtney Henry",
      "price": "₹40",
      "rating": "4.7",
      "icon": Icons.bug_report,
      "role": "pest_care",
    },
    {
      "subtitle": "Albert Flores",
      "price": "₹35",
      "rating": "4.5",
      "icon": Icons.grass,
      "role": "gardening",
    },
    {
      "subtitle": "Marvin McKinney",
      "price": "₹50",
      "rating": "4.8",
      "icon": Icons.window,
      "role": "glass_repair",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // For demo purposes, we match the first 3 letters of the role (e.g. "Car" for "Carpentry")
    final filteredServices = role == null
        ? services
        : services
              .where(
                (s) => s['role'].toString().toLowerCase().contains(
                  role!.toLowerCase().substring(0, 3),
                ),
              )
              .toList();

    // Show filtered services or all if none found (but now we have a carpenter!)
    final displayServices = filteredServices.isNotEmpty
        ? filteredServices
        : services;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        title: Text(
          role ?? 'Services',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: displayServices.length,
        itemBuilder: (context, index) {
          final service = displayServices[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Service Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      service['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  SizedBox(width: 16),

                  // Service Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          service['subtitle'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(service['rating'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Price and Button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${service['price']}/day',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceDetailPage(
                                workerName: service['subtitle'].toString(),
                                serviceName: role ?? 'Service',
                                role: service['role'].toString(),
                                price:
                                    int.tryParse(
                                      service['price'].toString().replaceAll(
                                        '₹',
                                        '',
                                      ),
                                    ) ??
                                    0,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Book',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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
