import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:clients/main.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class Booking extends StatefulWidget {
  final String id;
  const Booking({super.key, required this.id});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController jobDpt = TextEditingController();

  bool isLoading = false;
  late Map<String, dynamic> _serviceAccountConfig;

  @override
  void initState() {
    super.initState();
    _loadServiceAccountConfig(); // Load config once during initialization
  }

  Future<void> _loadServiceAccountConfig() async {
    _serviceAccountConfig = await loadConfig();
  }

  Future<void> book() async {
    setState(() => isLoading = true);

    try {
      // Convert time to 24-hour format (HH:mm:ss)
      final timeOfDay = TimeOfDay.fromDateTime(intl.DateFormat('hh:mm a').parse(time.text));
      final formattedTime = intl.DateFormat('HH:mm:ss').format(
        DateTime(2023, 1, 1, timeOfDay.hour, timeOfDay.minute),
      );

      await supabase.from('tbl_request').insert([
        {
          "sp_id": widget.id,
          'fordate': date.text,
          'fortime': formattedTime, // Use 24-hour format
          'description': jobDpt.text,
        }
      ]);

      final getCToken = await supabase.from('tbl_sp').select().eq('id', widget.id).single();
      final userToken = getCToken['fcm_token'] as String?;

      if (userToken != null) {
        await sendPushNotification(userToken);
      }

      print("Data inserted successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking submitted successfully!")),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        date.text = intl.DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        time.text = pickedTime.format(context);
      });
    }
  }

  Future<Map<String, dynamic>> loadConfig() async {
    try {
      // Adjust path based on your project structure
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

  Future<void> sendPushNotification(String userToken) async {
    try {
      final String serverKey = await getAccessToken();
      // Replace with your actual Firebase project ID
      const String projectId = 'flare-app-18697'; // Update this!
      final String fcmEndpoint =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final Map<String, dynamic> message = {
        'message': {
          'token': userToken,
          'notification': {
            'title': 'New Booking Request',
            'body': 'You have a new booking for ${date.text} at ${time.text}',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book a Service',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 252, 244, 88),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: date,
                      readOnly: true,
                      onTap: _pickDate,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: const TextStyle(color: Colors.black54),
                        prefixIcon: const Icon(Icons.calendar_today, color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: time,
                      readOnly: true,
                      onTap: _pickTime,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Time',
                        labelStyle: const TextStyle(color: Colors.black54),
                        prefixIcon: const Icon(Icons.access_time, color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      maxLines: 4,
                      controller: jobDpt,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Job Description',
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isLoading ? null : book,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit Booking',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 252, 244, 88),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Why Choose Us?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'We provide top-notch services with a focus on quality and customer satisfaction. Book now and experience the difference!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/kits.png',
                      height: 150,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}