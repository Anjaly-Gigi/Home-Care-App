import 'package:flutter/material.dart';
import 'package:serviceprovider/main.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class RequestView extends StatefulWidget {
  const RequestView({super.key});

  @override
  _RequestViewState createState() => _RequestViewState();
}

class _RequestViewState extends State<RequestView> with SingleTickerProviderStateMixin {
  String? serviceProviderId;
  List<Map<String, dynamic>> bookings = [];
  late TabController _tabController;
  late Map<String, dynamic> _serviceAccountConfig;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadServiceAccountConfig(); // Load config once
    fetchLoggedInServiceProviderId();
  }

  Future<void> _loadServiceAccountConfig() async {
    _serviceAccountConfig = await loadConfig();
  }

  Future<Map<String, dynamic>> loadConfig() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/services/config.json');
      print("Config Loaded: $jsonString");
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print("Error loading config.json: $e");
      return {};
    }
  }

  Future<String> getAccessToken() async {
    const List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    final client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(_serviceAccountConfig),
      scopes,
    );

    final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(_serviceAccountConfig),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }

  Future<void> sendPushNotification(String? userToken, String title, String body) async {
    if (userToken == null) {
      print("No FCM token found for client");
      return;
    }

    try {
      final String serverKey = await getAccessToken();
      const String projectId = 'flare-app-18697'; // Replace with your Firebase project ID
      final String fcmEndpoint =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final Map<String, dynamic> message = {
        'message': {
          'token': userToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'current_user_fcm_token': userToken,
          },
        }
      };

      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('FCM message sent successfully');
      } else {
        print('Failed to send FCM message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Failed Notification: $e");
    }
  }

  Future<void> fetchLoggedInServiceProviderId() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        serviceProviderId = user.id;
      });
      fetchData();
    }
  }

  Future<void> fetchData() async {
    if (serviceProviderId == null) return;
    try {
      final response = await supabase
          .from('tbl_request')
          .select('id, description, date, status, starttime, endtime, charge, sp_id, tbl_client (client_name, fcm_token)')
          .eq('sp_id', serviceProviderId!);

      setState(() {
        bookings = response.isNotEmpty ? List<Map<String, dynamic>>.from(response) : [];
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New Requests'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(0),
          _buildBookingList(1),
          _buildBookingList(2),
          _buildBookingList(6),
        ],
      ),
    );
  }

  Widget _buildBookingList(int status) {
    List<int> statuses;
    if (status == 1) {
      statuses = [1, 3]; // Approved: includes "Approved" and "In Progress"
    } else if (status == 6) {
      statuses = [4, 5]; // Completed: includes "Job Completed" and "Payment Completed"
    } else {
      statuses = [status];
    }

    final filteredBookings = bookings.where((b) => statuses.contains(b['status'])).toList();

    return filteredBookings.isEmpty
        ? const Center(child: Text('No bookings found'))
        : ListView.builder(
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(filteredBookings[index]);
            },
          );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${booking['tbl_client']['client_name'] ?? 'Unknown'}'),
            Text('Job: ${booking['description'] ?? 'N/A'}'),
            Text('Date: ${booking['date'] ?? 'N/A'}'),
            if (booking['status'] >= 3) Text('Start Time: ${booking['starttime'] ?? 'N/A'}'),
            if (booking['status'] >= 4) Text('End Time: ${booking['endtime'] ?? 'N/A'}'),
            if (booking['status'] >= 4)
              Text('Charge: \$${booking['charge'] != null ? booking['charge'].toString() : 'N/A'}'),
            const SizedBox(height: 10),
            _buildActionButtons(booking),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> booking) {
    switch (booking['status']) {
      case 0:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () => _updateStatus(booking['id'], 1, 'Request Accepted', 'Your booking has been accepted.'),
              child: const Text('Accept'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => _updateStatus(booking['id'], 2, 'Request Rejected', 'Your booking has been rejected.'),
              child: const Text('Reject'),
            ),
          ],
        );
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () => _startJob(booking['id']),
              child: const Text('Start Job'),
            ),
          ],
        );
      case 3:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => _showEndJobDialog(booking['id']),
              child: const Text('End Job'),
            ),
          ],
        );
      case 5:
        return ElevatedButton(
          onPressed: () => _markPaymentCompleted(booking['id']),
          child: const Text('Complete Payment'),
        );
      default:
        return const SizedBox();
    }
  }

  void _showEndJobDialog(int bookingId) {
    TextEditingController chargeController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Job'),
          content: TextField(
            controller: chargeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter Job Amount'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () {
                double charge = double.tryParse(chargeController.text) ?? 0.0;
                _endJob(bookingId, charge);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateStatus(int bookingId, int status, String title, String body) async {
    await supabase.from('tbl_request').update({'status': status}).match({'id': bookingId});
    final booking = bookings.firstWhere((b) => b['id'] == bookingId);
    await sendPushNotification(booking['tbl_client']['fcm_token'], title, body);
    fetchData();
  }

  void _startJob(int bookingId) async {
    String startTime = DateTime.now().toIso8601String();
    await supabase.from('tbl_request').update({'starttime': startTime, 'status': 3}).match({'id': bookingId});
    final booking = bookings.firstWhere((b) => b['id'] == bookingId);
    await sendPushNotification(booking['tbl_client']['fcm_token'], 'Job Started', 'Your job has started at $startTime.');
    fetchData();
  }

  void _endJob(int bookingId, double charge) async {
    DateTime end = DateTime.now();
    await supabase.from('tbl_request').update({'endtime': end.toIso8601String(), 'charge': charge, 'status': 5}).match({'id': bookingId});
    final booking = bookings.firstWhere((b) => b['id'] == bookingId);
    await sendPushNotification(booking['tbl_client']['fcm_token'], 'Job Ended', 'Your job has ended. Charge: \$$charge.');
    fetchData();
  }

  void _markPaymentCompleted(int bookingId) async {
    await supabase.from('tbl_request').update({'status': 6}).match({'id': bookingId});
    final booking = bookings.firstWhere((b) => b['id'] == bookingId);
    await sendPushNotification(booking['tbl_client']['fcm_token'], 'Payment Completed', 'Your payment has been completed.');
    fetchData();
  }
}