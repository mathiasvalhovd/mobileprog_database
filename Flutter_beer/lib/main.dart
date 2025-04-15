import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // The root widget of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic SQFlite Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
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
  
  // Controllers for dynamic form input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _numController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshRecords();
  }

  // Refresh the list of records from the database
  void _refreshRecords() {
    setState(() {
      recordsFuture = DatabaseHelper.instance.queryAllRecords();
    });
  }

  // Insert a new record using values from the text fields
  Future<void> _insertRecord() async {
    if (_nameController.text.isEmpty || _valueController.text.isEmpty || _numController.text.isEmpty) {
      return;
    }
    Map<String, dynamic> newRecord = {
      'name': _nameController.text,
      'value': int.tryParse(_valueController.text) ?? 0,
      'num': double.tryParse(_numController.text) ?? 0.0,
    };
    await DatabaseHelper.instance.insertRecord(newRecord);
    _nameController.clear();
    _valueController.clear();
    _numController.clear();
    _refreshRecords();
  }

  // Show a dialog to update an existing record
  void _showUpdateDialog(Map<String, dynamic> record) {
    // Create controllers pre-filled with the current values
    final TextEditingController updateNameController = TextEditingController(text: record['name'].toString());
    final TextEditingController updateValueController = TextEditingController(text: record['value'].toString());
    final TextEditingController updateNumController = TextEditingController(text: record['num'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: updateNameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: updateValueController,
              decoration: InputDecoration(labelText: 'Value'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: updateNumController,
              decoration: InputDecoration(labelText: 'Num'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Update'),
            onPressed: () async {
              Map<String, dynamic> updatedRecord = {
                'id': record['id'],
                'name': updateNameController.text,
                'value': int.tryParse(updateValueController.text) ?? 0,
                'num': double.tryParse(updateNumController.text) ?? 0.0,
              };
              await DatabaseHelper.instance.updateRecord(updatedRecord);
              Navigator.pop(context);
              _refreshRecords();
            },
          ),
        ],
      ),
    );
  }

  // Delete a record by id
  Future<void> _deleteRecord(int id) async {
    await DatabaseHelper.instance.deleteRecord(id);
    _refreshRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic SQFlite Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Form to add a new record
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _valueController,
              decoration: InputDecoration(labelText: 'Value', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _numController,
              decoration: InputDecoration(labelText: 'Num', border: OutlineInputBorder()),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _insertRecord,
              child: Text('Add Record'),
            ),
            SizedBox(height: 12),
            Divider(),
            // Display the list of records
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: recordsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final records = snapshot.data!;
                  if (records.isEmpty) {
                    return Center(child: Text('No records found.'));
                  }

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      var record = records[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        child: ListTile(
                          title: Text(record['name'].toString()),
                          subtitle: Text('Value: ${record['value']} | Num: ${record['num']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit button
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showUpdateDialog(record),
                              ),
                              // Delete button
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteRecord(record['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
