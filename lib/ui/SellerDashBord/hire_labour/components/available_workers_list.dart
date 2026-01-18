import 'package:flutter/material.dart';

class AvailableWorkersList extends StatelessWidget {
  final List<Map<String, dynamic>> labourers = [
    {
      'name': 'Ahmad Ali',
      'skill': 'Harvesting Expert',
      'experience': '5 years',
      'rating': 4.8,
      'location': 'Lahore',
      'dailyRate': '2500',
      'available': true,
    },
    {
      'name': 'Muhammad Hassan',
      'skill': 'Tractor Operator',
      'experience': '8 years',
      'rating': 4.9,
      'location': 'Faisalabad',
      'dailyRate': '3000',
      'available': true,
    },
    {
      'name': 'Ali Khan',
      'skill': 'Crop Specialist',
      'experience': '3 years',
      'rating': 4.7,
      'location': 'Multan',
      'dailyRate': '2200',
      'available': false,
    },
    {
      'name': 'Ali Raza',
      'skill': 'General Farm Work',
      'experience': '2 years',
      'rating': 4.5,
      'location': 'Sialkot',
      'dailyRate': '2000',
      'available': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: labourers.length,
      itemBuilder: (context, index) {
        final labourer = labourers[index];
        return _buildLabourCard(labourer);
      },
    );
  }

  Widget _buildLabourCard(Map<String, dynamic> labourer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.person, color: Colors.green[700], size: 30),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labourer['name'],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        labourer['skill'],
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${labourer['rating']} • ${labourer['experience']}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: labourer['available'] ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    labourer['available'] ? 'Available' : 'Busy',
                    style: TextStyle(
                      color: labourer['available'] ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                SizedBox(width: 4),
                Text(labourer['location'], style: TextStyle(color: Colors.grey[600])),
                Spacer(),
                Text(
                  'Rs. ${labourer['dailyRate']}/day',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: labourer['available'] ? () {
                  // Handle hire action
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: labourer['available'] ? Colors.green[700] : Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  labourer['available'] ? 'Hire Now' : 'Not Available',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}