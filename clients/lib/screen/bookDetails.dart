import 'dart:io';

import 'package:clients/main.dart';
import 'package:clients/screen/paymentpage.dart';
import 'package:clients/screen/rating.dart'; // Add this line
import 'package:flutter/material.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> with SingleTickerProviderStateMixin {
  String? clientId;
  List<Map<String, dynamic>> bookings = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchLoggedInClientId();
  }

  Future<void> fetchLoggedInClientId() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        clientId = user.id;
      });
      fetchData();
    }
  }

  void fetchData() async {
    if (clientId == null) return;

    try {
      final response = await supabase
          .from('tbl_request')
          .select()
          .eq('client_id', clientId!);

      if (response != null) {
        setState(() {
          bookings = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
            Tab(text: 'Review'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList([0, 1, 3]), // Upcoming and confirmed
          _buildBookingList([4, 5]), // Completed
          _buildBookingList([2]), // Cancelled
          _buildReviewList([5, 6]), // Review
        ],
      ),
    );
  }

  Widget _buildBookingList(List<int> statuses) {
    final filteredBookings = bookings.where((b) => statuses.contains(b['status'])).toList();

    return filteredBookings.isEmpty
        ? const Center(child: Text('No bookings found.'))
        : ListView.builder(
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              final booking = filteredBookings[index];
              return _buildBookingCard(booking);
            },
          );
  }

 Widget _buildReviewList(List<int> statuses) {
  final filteredBookings = bookings.where((b) => statuses.contains(b['status'])).toList();

  return filteredBookings.isEmpty
      ? const Center(child: Text('No reviews to write.'))
      : Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Your feedback helps us improve.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  final booking = filteredBookings[index];
                  return Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
                      },
                      child: const Text('Write a Review'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
}


  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(12),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.work, 'Job Description', booking['description'] ?? 'N/A'),
            _buildDetailRow(Icons.calendar_today, 'Date', booking['fordate'] ?? 'N/A'),
            _buildDetailRow(Icons.access_time, 'Time', booking['fortime'] ?? 'N/A'),
            if (booking['status'] >= 4) ...[
              _buildDetailRow(Icons.timer, 'Start Time', booking['starttime'] ?? 'N/A'),
              _buildDetailRow(Icons.timer_off, 'End Time', booking['endtime'] ?? 'N/A'),
              const SizedBox(height: 12),
              Card(
                color: Colors.white,
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Charge:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(booking['charge'] != null ? '\$${booking['charge']}' : 'N/A'),
                        ],
                      ),
                      const Divider(),
                      if (booking['status'] == 5)
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PaymentGatewayScreen(bookingId: booking['id'])),
                              );
                            },
                            child: const Text('Proceed to pay'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _payNow(int bookingId) async {
    await supabase.from('tbl_request').update({'status': 6}).match({'id': bookingId});
    fetchData();
  }
}
