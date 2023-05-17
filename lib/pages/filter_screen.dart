import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterScreen extends StatefulWidget {
  final Function(List<DocumentSnapshot>?) onFilterApplied;

  const FilterScreen({Key? key, required this.onFilterApplied})
      : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int minPrice = 0;
  int maxPrice = 2000;
  int minRooms = 1;
  int maxRooms = 5;
  int minBathrooms = 1;
  int maxBathrooms = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 15),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Color(0xff25262b),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text('Filtrar',
              style: GoogleFonts.dmSans(
                color: const Color(0xff25262b),
                fontWeight: FontWeight.w500,
              )),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 30, top: 30),
                  child: Text(
                    'Preferències',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'dmSans',
                      fontSize: 24,
                      color: Color(0xff25262b),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: ListTile(
                  subtitle: FlutterSlider(
                    handlerHeight: 25,
                    handlerWidth: 25,
                    values: [minPrice.toDouble(), maxPrice.toDouble()],
                    rangeSlider: true,
                    min: 0,
                    max: 2000,
                    step: FlutterSliderStep(
                        step: 100), // Set the step size to 100
                    onDragging: (handlerIndex, lowerValue, upperValue) {
                      setState(() {
                        minPrice = (lowerValue / 100).round() *
                            100; // Adjust the values in increments of 100
                        maxPrice = (upperValue / 100).round() * 100;
                      });
                    },
                    trackBar: FlutterSliderTrackBar(
                      activeTrackBar: BoxDecoration(color: Color(0xFF1FA29E)),
                      inactiveTrackBar:
                          BoxDecoration(color: Colors.grey.shade300),
                    ),
                    tooltip: FlutterSliderTooltip(
                      textStyle: TextStyle(fontSize: 17),
                      custom: (value) {
                        return Text('${value.toInt().toString()}',
                            style: TextStyle(fontSize: 17));
                      },
                    ),
                    handler: FlutterSliderHandler(
                      child: Container(),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                    rightHandler: FlutterSliderHandler(
                      child: Container(),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Min Price: $minPrice'),
                Text('Max Price: $maxPrice'),
              ],
            ),
          ),

          //use a dropdown button for min and max rooms
          ListTile(
            title: Text('Number of Rooms'),
            subtitle: RangeSlider(
              values: RangeValues(minRooms.toDouble(), maxRooms.toDouble()),
              min: 1,
              max: 5,
              activeColor: Color(0xFF1FA29E),
              inactiveColor: Colors.grey.shade300,
              onChanged: (RangeValues values) {
                setState(() {
                  minRooms = values.start.toInt();
                  maxRooms = values.end.toInt();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Min Rooms: $minRooms'),
                Text('Max Rooms: $maxRooms'),
              ],
            ),
          ),
          //Create ListTile for min and max bathrooms
          ListTile(
            title: Text('Number of Bathrooms'),
            subtitle: RangeSlider(
              values:
                  RangeValues(minBathrooms.toDouble(), maxBathrooms.toDouble()),
              min: 1,
              max: 5,
              activeColor: Color(0xFF1FA29E),
              inactiveColor: Colors.grey.shade300,
              onChanged: (RangeValues values) {
                setState(() {
                  minBathrooms = values.start.toInt();
                  maxBathrooms = values.end.toInt();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Min Bathrooms: $minBathrooms'),
                Text('Max Bathrooms: $maxBathrooms'),
              ],
            ),
          ),
          //Create a button to apply the filters
          ElevatedButton(
            onPressed: () {
              filterHouses();
            },
            child: Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  void filterHouses() {
    //house collection in firebase
    final housesCollection = FirebaseFirestore.instance.collection('houses');

    //price Query
    Query priceQuery = housesCollection;

    if (minPrice != 0 || maxPrice != 2000) {
      if (minPrice != 0 && maxPrice != 2000) {
        priceQuery = priceQuery.where('price',
            isGreaterThanOrEqualTo: minPrice, isLessThan: maxPrice + 1);
      } else if (minPrice != 0) {
        priceQuery =
            priceQuery.where('price', isGreaterThanOrEqualTo: minPrice);
      } else {
        priceQuery = priceQuery.where('price', isLessThan: maxPrice + 1);
      }
    }

    //get the houses that match the price filter
    priceQuery.get().then((QuerySnapshot querySnapshot) {
      List<DocumentSnapshot> filteredHouses = querySnapshot.docs;

      print('Filtered Houses (Price): ${filteredHouses.length}');

      //rooms Query
      Query roomsQuery = housesCollection;

      //if the min and max rooms are not the default values
      if (minRooms != 1 || maxRooms != 5) {
        if (minRooms != 1 && maxRooms != 5) {
          roomsQuery = roomsQuery.where('n_rooms',
              isGreaterThanOrEqualTo: minRooms, isLessThanOrEqualTo: maxRooms);
        } else if (minRooms != 1) {
          roomsQuery =
              roomsQuery.where('n_rooms', isGreaterThanOrEqualTo: minRooms);
        } else {
          roomsQuery =
              roomsQuery.where('n_rooms', isLessThanOrEqualTo: maxRooms);
        }
      }

      //get the houses that match the rooms filter
      roomsQuery.get().then((QuerySnapshot roomsSnapshot) {
        List<DocumentSnapshot> filteredRooms = roomsSnapshot.docs;
        print('Filtered Houses (Rooms): ${filteredRooms.length}');

        //bathrooms Query
        Query bathroomQuery = housesCollection;

        //if the min and max rooms are not the default values
        if (minBathrooms != 1 || maxBathrooms != 5) {
          if (minBathrooms != 1 && maxBathrooms != 5) {
            bathroomQuery = bathroomQuery.where('n_bathroom',
                isGreaterThanOrEqualTo: minBathrooms,
                isLessThanOrEqualTo: maxBathrooms);
          } else if (minBathrooms != 1) {
            bathroomQuery = bathroomQuery.where('n_bathroom',
                isGreaterThanOrEqualTo: minBathrooms);
          } else {
            bathroomQuery = bathroomQuery.where('n_bathroom',
                isLessThanOrEqualTo: maxBathrooms);
          }
        }

        //get the houses that match the rooms filter
        bathroomQuery.get().then((QuerySnapshot bathroomSnapshot) {
          List<DocumentSnapshot> filteredBathrooms = bathroomSnapshot.docs;
          print('Filtered Houses (Bathrooms): ${filteredBathrooms.length}');

          List<DocumentSnapshot> final2FilteredHouses = [];

          for (var house in filteredHouses) {
            var roomId = house.id;
            var matchingRooms =
                filteredRooms.where((room) => room.id == roomId);
            var matchingBathrooms =
                filteredBathrooms.where((bathroom) => bathroom.id == roomId);

            if (matchingRooms.isNotEmpty && matchingBathrooms.isNotEmpty) {
              final2FilteredHouses.add(house);
            }
          }

          print('Final Filtered Houses: ${final2FilteredHouses.length}');

          widget.onFilterApplied(final2FilteredHouses);

          Navigator.pop(context);
        });
      });
    });
  }
}
