import 'package:flutter/material.dart';

class LabourProfileDetail extends StatelessWidget {
  final Map<String, dynamic> profile;

  const LabourProfileDetail({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E5E25),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F9F1), Color(0xFFE8F5E8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPersonalInfoCard(),
              const SizedBox(height: 16),
              _buildSkillsCard(),
              const SizedBox(height: 16),
              _buildExperienceCard(),
              const SizedBox(height: 16),
              _buildAvailabilityCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF1F9F1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF2E5E25),
                    child: Text(
                      profile['name']?.toString().substring(0, 1).toUpperCase() ?? 'L',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile['name'] ?? 'Not specified',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(profile['phone'] ?? 'Not specified'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(profile['address'] ?? 'Not specified')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsCard() {
    final skills = profile['skills'] as List? ?? [];
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF1F9F1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.build, color: Color(0xFF2E5E25), size: 20),
                  SizedBox(width: 8),
                  Text('Skills & Expertise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5E25))),
                ],
              ),
              const SizedBox(height: 16),
              skills.isEmpty
                  ? const Text('No skills specified')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((skill) => 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E5E25).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF2E5E25).withOpacity(0.3)),
                          ),
                          child: Text(skill.toString(), style: const TextStyle(fontWeight: FontWeight.w500)),
                        )
                      ).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF1F9F1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.work, color: Color(0xFF2E5E25), size: 20),
                  SizedBox(width: 8),
                  Text('Experience & Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5E25))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.work_history, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Experience: ${profile['experience'] ?? 'Not specified'}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.money, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Daily Rate: Rs ${profile['dailyRate'] ?? 0}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Hourly Rate: Rs ${profile['hourlyRate'] ?? 0}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF1F9F1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.schedule, color: Color(0xFF2E5E25), size: 20),
                  SizedBox(width: 8),
                  Text('Availability & Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5E25))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Availability: ${profile['availability'] ?? 'Not specified'}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    profile['isAvailable'] == true ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: profile['isAvailable'] == true ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${profile['isAvailable'] == true ? 'Available for work' : 'Currently busy'}',
                    style: TextStyle(
                      color: profile['isAvailable'] == true ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (profile['description'] != null && profile['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(profile['description'].toString()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}