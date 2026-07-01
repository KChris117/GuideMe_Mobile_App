import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/controllers/destination_controller.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/models/destination_model.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:intl/intl.dart'; // Import DateFormat

class DestinationManagementScreen extends StatefulWidget {
  const DestinationManagementScreen({super.key});

  @override
  _DestinationScreenState createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationManagementScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String page = 'destination';

  @override
  void initState() {
    super.initState();

    // Memulai pengecekan status destination secara periodik
    DestinationController().scheduleDestinationStatusCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: BurgerAppBar(scaffoldKey: scaffoldKey),
      drawer: CustomAdminSidebar(
        onLogout: () {
          handleLogout(context);
        },
      ),
      body: DestinationScreenContent(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: AddButton(page),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 1),
    );
  }
}

class DestinationScreenContent extends StatelessWidget {
  final DestinationController _destinationController = DestinationController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomTitle(firstText: 'Hi, Admin!', secondText: 'Design your data exactly how you want it'),
            ],
          ),
          SizedBox(height: 16),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('destinations').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Card(
                  color: AppColors.backgroundColor,
                  elevation: 4.0, // Menambahkan shadow pada card
                  shape: RoundedRectangleBorder(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.accentColor), // Warna latar belakang header
                      headingTextStyle: AppTextStyles.mediumBlack.copyWith(
                        color: Colors.white, // Warna teks header
                        fontWeight: FontWeight.bold, // Menebalkan teks header
                      ),
                      columns: [
                        DataColumn(label: Text('Destination Name')),
                        DataColumn(label: Text('Location')),
                        DataColumn(label: Text('Subcategory')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                        DestinationModel destinationModel = DestinationModel.fromMap(data, doc.id);

                        // Format openingTime dan closingTime
                        // String openingTimeFormatted = DateFormat('yyyy-MM-dd HH:mm').format(destinationModel.openingTime.toDate());
                        // String closingTimeFormatted = DateFormat('yyyy-MM-dd HH:mm').format(destinationModel.closingTime.toDate());

                        return DataRow(
                          cells: [
                            DataCell(Text(destinationModel.name)),
                            DataCell(Text(destinationModel.location)),
                            DataCell(Text(destinationModel.subcategory)),
                            DataCell(
                              Row(
                                children: [
                                  EditButton(data: destinationModel, page: 'destination'),
                                  SizedBox(width: 8.0),
                                  DeleteButton(
                                    itemId: destinationModel.destinationId,
                                    itemName: destinationModel.name,
                                    itemType: 'destination',
                                    controller: _destinationController,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
