import 'package:clients/main.dart';
import 'package:clients/screen/bookDetails.dart';
import 'package:clients/screen/changePassword.dart';
import 'package:clients/screen/complaintpage.dart';
import 'package:clients/screen/editprofile.dart';
import 'package:clients/screen/viewComplaints.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientProfile extends StatefulWidget {
  const ClientProfile({super.key});

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  bool isLoading = true;
  Map<String, dynamic> clientData = {};

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await supabase
          .from('tbl_client')
          .select("*,tbl_place(*, tbl_district(*))")
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      print("Data Fetched Successfully");
      setState(() {
        clientData = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved Gradient Header
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: CurveClipper(),
                  child: Container(
                    height: 250,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                            const Color(0xFFFF6F61),
              const Color.fromARGB(255, 175, 238, 238),             
             
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // Profile Picture
                Positioned(
                  top: 150,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        clientData.isNotEmpty && clientData['client_name'] != null
                            ? clientData['client_name'][0]
                            : '?',
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            // Client Name
            Text(
              clientData.isNotEmpty ? clientData['client_name'] : 'No Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 7, 2, 2),
              ),
            ),
            const SizedBox(height: 20),
            // Buttons
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: [
                _buildButton('Edit Profile', Icons.edit, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Editpro()));
                }),
                _buildButton('My Booking', Icons.book, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyBooking()));
                }),
                _buildButton('Change Password', Icons.lock, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => passwordChange()));
                }),
                _buildButton('Report Complaints', Icons.report, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintPage()));
                }),
                _buildButton('My Complaints', Icons.find_in_page_rounded, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewComplaint()));
                }),
              ],
            ),
            const SizedBox(height: 30),
            // Client Details
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.email, 'Email', clientData['client_email'] ?? 'No Email'),
                          _buildDetailRow(Icons.location_on, 'Address', clientData['client_address'] ?? 'No Address'),
                          _buildDetailRow(Icons.phone, 'Contact', clientData['client_contact'].toString() ?? 'No Contact'),
                          _buildDetailRow(Icons.place, 'Place', clientData['tbl_place']['place_name'] ?? 'No Place'),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Button Widget
  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:const Color.fromARGB(255, 0, 128, 128),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 5),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Detail Row Widget
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 0, 128, 128), size: 30),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for Curved Header
class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
