import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Benefit {
  String name;
  String? details;
  bool isEdited;

  Benefit({required this.name, this.details, this.isEdited = false});
}

class BenefitsScreen extends StatefulWidget {
  @override
  _BenefitsScreenState createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen> {
  List<Benefit> benefits = [
    Benefit(name: 'Fitness'),
    Benefit(name: 'Internet'),
    Benefit(name: 'Education'),
    Benefit(name: 'BYOD'),
  ]; // Updated list of benefits

  void _showBenefitDetailsDialog({Benefit? benefit}) {
    TextEditingController benefitNameController =
        TextEditingController(text: benefit?.name);
    TextEditingController amountController = TextEditingController();
    String frequency = "every"; // Default frequency
    String selectedNumber = '1'; // Default number
    String timeUnit = "year"; // Default time unit
    bool isNewBenefit = benefit == null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Use StatefulBuilder to update the dialog's content
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                  isNewBenefit ? 'Add New Benefit' : 'Edit Benefit Details'),
              // Inside the AlertDialog, within the StatefulBuilder
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (isNewBenefit)
                      TextField(
                        controller: benefitNameController,
                        decoration: InputDecoration(hintText: "Benefit Name"),
                      ),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(hintText: "Amount"),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: frequency,
                            onChanged: (String? newValue) {
                              setStateDialog(() {
                                frequency = newValue!;
                              });
                            },
                            items: <String>['every', 'once in']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                            width:
                                8), // Provide some spacing between the dropdowns
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedNumber,
                            onChanged: (String? newValue) {
                              setStateDialog(() {
                                selectedNumber = newValue!;
                              });
                            },
                            items: List.generate(11, (index) => '${index + 1}')
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                            width:
                                8), // Provide some spacing between the dropdowns
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: timeUnit,
                            onChanged: (String? newValue) {
                              setStateDialog(() {
                                timeUnit = newValue!;
                              });
                            },
                            items: <String>['year', 'month']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              actions: <Widget>[
                TextButton(
                  child: Text('CANCEL'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('SAVE'),
                  onPressed: () {
                    // Construct the detail string
                    String detailString =
                        "${amountController.text} for $frequency $selectedNumber $timeUnit";
                    if (isNewBenefit) {
                      setState(() {
                        benefits.add(Benefit(
                            name: benefitNameController.text,
                            details: detailString,
                            isEdited: true));
                      });
                    } else if (benefit != null) {
                      setState(() {
                        benefit.details = detailString;
                        benefit.isEdited = true;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Benefits', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: benefits.length,
        itemBuilder: (context, index) {
          Benefit benefit = benefits[index];
          return Card(
            color: benefit.isEdited ? Colors.blue.shade100 : Colors.white,
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                benefit.name +
                    (benefit.details != null ? ' - ${benefit.details}' : ''),
                style: TextStyle(color: Colors.blue),
              ),
              trailing: Wrap(
                spacing: 12, // Space between two icons
                children: <Widget>[
                  if (benefit.isEdited)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          benefit.details = null;
                          benefit.isEdited = false;
                        });
                      },
                      child: Icon(Icons.clear, color: Colors.red),
                    ),
                  GestureDetector(
                    onTap: () => _showBenefitDetailsDialog(benefit: benefit),
                    child: Icon(Icons.edit, color: Colors.blue),
                  ),
                ],
              ),
              onTap: () => _showBenefitDetailsDialog(benefit: benefit),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Adjusted to add a new benefit.
        onPressed: () => _showBenefitDetailsDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: ElevatedButton(
            onPressed: () {
              saveAllBenefitsToFirebase().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All benefits saved successfully')),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save benefits')),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Use a darker shade if you prefer
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Save All',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18, // Larger font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveAllBenefitsToFirebase() async {
    print("Attempting to save all edited benefits...");
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference benefitsCollection =
        firestore.collection('userBenefits');

    List<Benefit> editedBenefits =
        benefits.where((benefit) => benefit.isEdited).toList();

    if (editedBenefits.isEmpty) {
      print("No edited benefits to save.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No edited benefits to save')),
      );
      return;
    }

    for (var benefit in editedBenefits) {
      await benefitsCollection.doc(benefit.name).set({
        'details': benefit.details ?? 'Not specified',
        'isEdited': false // Optionally reset the isEdited flag after saving
      }, SetOptions(merge: true)).catchError((error) {
        print("Failed to save benefit: $error");
        // Optionally handle or log the error
      });
    }

    print("All edited benefits have been saved.");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All edited benefits saved successfully')),
    );

    // Reset the isEdited flag locally after successful save
    setState(() {
      for (var benefit in editedBenefits) {
        benefit.isEdited = false;
      }
    });
  }
}
