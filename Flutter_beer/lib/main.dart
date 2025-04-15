import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // The root of the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Map<String, dynamic>>>? recordsFuture;

  @override
  void initState() {
    super.initState();
    _refreshRecords();
  }

  // Refresh the records by querying the database
  void _refreshRecords() {
    setState(() {
      recordsFuture = DatabaseHelper.instance.queryAllRecords();
    });
  }

  // Insert a sample record into the database
  Future<void> _insertSampleRecord() async {
    Map<String, dynamic> sampleRecord = {
      'name': 'Sample',
      'value': 42,
      'num': 3.14,
    };
    await DatabaseHelper.instance.insertRecord(sampleRecord);
    _refreshRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQFlite Example'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: recordsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Show a loading spinner while data loads
            return Center(child: CircularProgressIndicator());
          }
          List<Map<String, dynamic>> records = snapshot.data!;
          if (records.isEmpty) {
            return Center(child: Text('No records found.'));
          }
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              var record = records[index];
              return ListTile(
                title: Text(record['name'].toString()),
                subtitle: Text('Value: ${record['value']}, Num: ${record['num']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _insertSampleRecord,
        tooltip: 'Add Record',
        child: Icon(Icons.add),
      ),
    );
  }
}
