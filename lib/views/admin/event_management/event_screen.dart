import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/controllers/event_controller.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/models/event_model.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:intl/intl.dart'; // Import DateFormat

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventManagementScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String page = 'event';

  late ScrollController _scrollController;
  double _paddingLeft = 12.0;
  double _paddingRight = 0.0;

  @override
  void initState() {
    super.initState();

    // Memulai pengecekan status event secara periodik
    EventController().scheduleEventStatusCheck();

    _scrollController = ScrollController();
    // Menambahkan listener untuk mendeteksi perubahan scroll
    // _scrollController.addListener(() {
    //   double currentScrollPosition = _scrollController.position.pixels;
    //   double maxScrollExtent = _scrollController.position.maxScrollExtent;

    //   // Jika scroll mencapai batas maksimum
    //   if (currentScrollPosition >= maxScrollExtent) {
    //     if (_paddingRight != 16.0) {
    //       setState(() {
    //         _paddingLeft = 0.0;
    //         _paddingRight = 16.0; // Padding kanan saat scroll mencapai batas maksimum
    //       });
    //     }
    //   }
    //   // Jika scroll berada di awal
    //   else if (currentScrollPosition <= 0) {
    //     if (_paddingLeft != 16.0) {
    //       setState(() {
    //         _paddingLeft = 16.0; // Padding kiri saat scroll di awal
    //         _paddingRight = 0.0; // Padding kanan saat scroll di awal
    //       });
    //     }
    //   }
    //   // Jika scroll berada di tengah konten
    //   else {
    //     if (_paddingLeft != 0.0 || _paddingRight != 0.0) {
    //       setState(() {
    //         _paddingLeft = 0.0; // Padding kiri menjadi 0
    //         _paddingRight = 0.0; // Padding kanan menjadi 0
    //       });
    //     }
    //   }
    // });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Pastikan untuk membuang controller
    super.dispose();
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          double currentScrollPosition = _scrollController.position.pixels;
          double maxScrollExtent = _scrollController.position.maxScrollExtent;

          // Jika scroll mencapai batas maksimum
          if (scrollInfo.metrics.atEdge) {
            if (scrollInfo.metrics.pixels == maxScrollExtent) {
              if (_paddingRight != 16.0) {
                setState(() {
                  _paddingLeft = 0.0;
                  _paddingRight = 16.0; // Padding kanan saat scroll mencapai batas maksimum
                });
              }
            } else if (scrollInfo.metrics.pixels == 0) {
              if (_paddingLeft != 16.0) {
                setState(() {
                  _paddingLeft = 16.0; // Padding kiri saat scroll di awal
                  _paddingRight = 0.0; // Padding kanan saat scroll di awal
                });
              }
            }
          } else {
            // Jika scroll berada di tengah konten
            if (_paddingLeft != 0.0 || _paddingRight != 0.0) {
              setState(() {
                _paddingLeft = 0.0; // Padding kiri menjadi 0
                _paddingRight = 0.0; // Padding kanan menjadi 0
              });
            }
          }
          return true; // Mengindikasikan bahwa notifikasi telah ditangani
        },
        child: EventScreenContent(
          scrollController: _scrollController,
          paddingLeft: _paddingLeft,
          paddingRight: _paddingRight,
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: AddButton(page),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 2),
    );
  }
}

class EventScreenContent extends StatelessWidget {
  final EventController _eventController = EventController();
  final ScrollController scrollController;
  final double paddingLeft;
  final double paddingRight;

  EventScreenContent({
    Key? key,
    required this.scrollController,
    required this.paddingLeft,
    required this.paddingRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomTitle(firstText: 'Hi, Admin!', secondText: 'Design your data exactly how you want it'),
            ],
          ),
          SizedBox(height: 16),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('events').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: scrollController,
                // physics: AlwaysScrollableScrollPhysics(),
                child: AnimatedPadding(
                  padding: EdgeInsets.only(left: paddingLeft, right: paddingRight),
                  duration: Duration(milliseconds: 200), // Durasi animasi
                  child: Card(
                    color: AppColors.backgroundColor,
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.accentColor), // Warna latar belakang header
                      headingTextStyle: AppTextStyles.mediumBlack.copyWith(
                        color: Colors.white, // Warna teks header
                        fontWeight: FontWeight.bold, // Menebalkan teks header
                      ),
                      columns: [
                        DataColumn(label: Text('Event Name')),
                        DataColumn(label: Text('Location')),
                        DataColumn(label: Text('Subategory')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                        EventModel eventModel = EventModel.fromMap(data, doc.id);

                        // Format openingTime dan closingTime
                        String openingTimeFormatted = DateFormat('yyyy-MM-dd HH:mm').format(eventModel.openingTime.toDate());
                        String closingTimeFormatted = DateFormat('yyyy-MM-dd HH:mm').format(eventModel.closingTime.toDate());

                        return DataRow(
                          cells: [
                            DataCell(Text(eventModel.name)),
                            DataCell(Text(eventModel.location)),
                            DataCell(Text(eventModel.subcategory)),
                            DataCell(
                              Row(
                                children: [
                                  EditButton(
                                    data: eventModel,
                                    page: 'event',
                                  ),
                                  SizedBox(width: 8.0),
                                  DeleteButton(
                                    itemId: eventModel.eventId,
                                    itemName: eventModel.name,
                                    itemType: 'event',
                                    controller: _eventController,
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

// class EventScreenContent extends StatelessWidget {
//   final EventController _eventController = EventController();
//   final Map<String, bool> showButtons = {};

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance.collection('events').snapshots(),
//       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             var doc = snapshot.data!.docs[index];
//             Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//             EventModel event = EventModel.fromMap(data, doc.id);

//             // Inisialisasi status tombol untuk setiap event
//             showButtons.putIfAbsent(event.eventId, () => false);

//             return Padding(
//               padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
//               child: Card(
//                 elevation: 5,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: ExpansionTile(
//                   title: Text(event.name),
//                   subtitle: Text('Location: ${event.location}'),
//                   leading: event.imageUrl.startsWith('/')
//                       ? Image.file(
//                           File(event.imageUrl),
//                           fit: BoxFit.cover,
//                           width: 60,
//                           height: 60,
//                         )
//                       : Image.network(
//                           event.imageUrl,
//                           fit: BoxFit.cover,
//                           width: 60,
//                           height: 60,
//                         ),
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Latitude: ${event.latitude}'),
//                           Text('Longitude: ${event.longitude}'),
//                           Text('Organizer: ${event.organizer}'),
//                           Text('Category: ${event.category}'),
//                           Text('Description: ${event.description}'),
//                           Text('Information: ${event.information}'),
//                           Text('Rating: ${event.rating}'),
//                           Text('Price: ${event.price}'),
//                           Text('Opening Time: ${event.openingTime}'),
//                           Text('Closing Time: ${event.closingTime}'),
//                           Text('Created At: ${event.createdAt.toDate()}'),
//                           SizedBox(height: 10),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               FloatingActionButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           ModifyEventScreen(event: event),
//                                     ),
//                                   );
//                                 },
//                                 mini: true,
//                                 backgroundColor: Colors.yellow,
//                                 child: Icon(Icons.edit, color: Colors.white),
//                               ),
//                               SizedBox(width: 8),
//                               FloatingActionButton(
//                                 onPressed: () async {
//                                   bool? confirmDelete = await showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       return AlertDialog(
//                                         title: Text('Delete Event'),
//                                         content: Text(
//                                             'Are you sure you want to delete this event?'),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () =>
//                                                 Navigator.of(context).pop(false),
//                                             child: Text('Cancel'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () =>
//                                                 Navigator.of(context).pop(true),
//                                             child: Text('Delete'),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );

//                                   if (confirmDelete == true) {
//                                     await _eventController.deleteEvent(event.eventId);
//                                   }
//                                 },
//                                 mini: true,
//                                 backgroundColor: Colors.red,
//                                 child: Icon(Icons.delete, color: Colors.white),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
