import 'package:flutter/material.dart';
import 'package:near_you/model/treatment.dart';
import 'package:near_you/widgets/static_components.dart';
import 'package:intl/intl.dart';

class CalendarTimeline extends StatefulWidget {
  ValueChanged<String> onChanged;

  CalendarTimeline({required this.onChanged});

  @override
  CalendarTimelineState createState() => CalendarTimelineState(onChanged);
}

class CalendarItem {
  String day, number;
  String dateId;

  CalendarItem(this.day, this.number, this.dateId);
}

class CalendarTimelineState extends State<CalendarTimeline> {
  static StaticComponents staticComponents = StaticComponents();
  late final Future<Treatment> currentTreatmentFuture;
  List<CalendarItem> datesList = <CalendarItem>[];
  ValueChanged<String> onChanged;

  var selectedIndex = 6;

  CalendarTimelineState(this.onChanged);

  @override
  void initState() {
    DateTime aWeekAgo =  DateTime.now().subtract(Duration(days: 6));
    for (int i = 0; i < 7; i++) {
      DateTime currentDate = aWeekAgo.add(Duration(days: i));
      datesList.add(CalendarItem(
          getWeekday(currentDate.weekday),
          currentDate.day.toString(),
          DateFormat('dd-MMM-yyyy').format(currentDate)));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      child: Container(
        height: 50,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xff2F8F9D)),
                onPressed: () {
                  goBack();
                },
              ),
              Expanded(
                //apply padding to all four sides
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: selectedIndex == 0
                              ? BoxDecoration(
                                  color: Color(0xff2F8F9D),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                )
                              : BoxDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                datesList[0].day,
                                style: TextStyle(
                                    color: selectedIndex == 0
                                        ? Colors.white
                                        : Color(0xff666666),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300),
                              ),
                              SizedBox(height: 5),
                              Text(datesList[0].number,
                                  style: TextStyle(
                                      color: selectedIndex == 0
                                          ? Colors.white
                                          : Color(0xff666666),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                        ),
                        onTap: () {
                          changeSelected(0);
                        },
                      ),
                      InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: selectedIndex == 1
                                ? BoxDecoration(
                                    color: Color(0xff2F8F9D),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  )
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  datesList[1].day,
                                  style: TextStyle(
                                      color: selectedIndex == 1
                                          ? Colors.white
                                          : Color(0xff666666),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(height: 5),
                                Text(datesList[1].number,
                                    style: TextStyle(
                                        color: selectedIndex == 1
                                            ? Colors.white
                                            : Color(0xff666666),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ],
                            ),
                          ),
                          onTap: () {
                            changeSelected(1);
                          }),
                      InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: selectedIndex == 2
                                ? BoxDecoration(
                                    color: Color(0xff2F8F9D),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  )
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  datesList[2].day,
                                  style: TextStyle(
                                      color: selectedIndex == 2
                                          ? Colors.white
                                          : Color(0xff666666),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(height: 5),
                                Text(datesList[2].number,
                                    style: TextStyle(
                                        color: selectedIndex == 2
                                            ? Colors.white
                                            : Color(0xff666666),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ],
                            ),
                          ),
                          onTap: () {
                            changeSelected(2);
                          }),
                      InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: selectedIndex == 3
                                ? BoxDecoration(
                                    color: Color(0xff2F8F9D),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  )
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  datesList[3].day,
                                  style: TextStyle(
                                      color: selectedIndex == 3
                                          ? Colors.white
                                          : Color(0xff666666),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(height: 5),
                                Text(datesList[3].number,
                                    style: TextStyle(
                                        color: selectedIndex == 3
                                            ? Colors.white
                                            : Color(0xff666666),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ],
                            ),
                          ),
                          onTap: () {
                            changeSelected(3);
                          }),
                      InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: selectedIndex == 4
                                ? BoxDecoration(
                                    color: Color(0xff2F8F9D),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  )
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  datesList[4].day,
                                  style: TextStyle(
                                      color: selectedIndex == 4
                                          ? Colors.white
                                          : Color(0xff666666),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(height: 5),
                                Text(datesList[4].number,
                                    style: TextStyle(
                                        color: selectedIndex == 4
                                            ? Colors.white
                                            : Color(0xff666666),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ],
                            ),
                          ),
                          onTap: () {
                            changeSelected(4);
                          }),
                      InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: selectedIndex == 5
                                ? BoxDecoration(
                                    color: Color(0xff2F8F9D),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  )
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  datesList[5].day,
                                  style: TextStyle(
                                      color: selectedIndex == 5
                                          ? Colors.white
                                          : Color(0xff666666),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(height: 5),
                                Text(datesList[5].number,
                                    style: TextStyle(
                                        color: selectedIndex == 5
                                            ? Colors.white
                                            : Color(0xff666666),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ],
                            ),
                          ),
                          onTap: () {
                            changeSelected(5);
                          }),
                      InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: selectedIndex == 6
                                ? BoxDecoration(
                                    color: Color(0xff2F8F9D),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  )
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  datesList[6].day,
                                  style: TextStyle(
                                      color: selectedIndex == 6
                                          ? Colors.white
                                          : Color(0xff666666),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(height: 5),
                                Text(datesList[6].number,
                                    style: TextStyle(
                                        color: selectedIndex == 6
                                            ? Colors.white
                                            : Color(0xff666666),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ],
                            ),
                          ),
                          onTap: () {
                            changeSelected(6);
                          }),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, color: Color(0xff2F8F9D)),
                onPressed: () {
                  goAhead();
                },
              )
            ]),
      ),
    );

    /* return Container(
      height: 80,
      width: screenWidth,
      color: Colors.red,
      child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: 3,
          itemBuilder: (ctx, i) => getCurrentPageByIndex(ctx, i)),
    );*/
  }

  void goAhead() {
    List<CalendarItem> datesListCopy = datesList;
    DateTime first =
    DateFormat('dd-MMM-yyyy').parse(datesList[6].dateId).add(const Duration(days: 1));
    /* Localizations.localeOf(context).languageCode*/
    String firstFormattedDate = DateFormat('dd-MMM-yyyy').format(first);
    CalendarItem newDate = CalendarItem(
        getWeekday(first.weekday), first.day.toString(), firstFormattedDate);
    datesListCopy.removeAt(0);
    datesListCopy.add(newDate);

    setState(() {
      datesList = datesListCopy;
    });

  }

  void goBack() {
    List<CalendarItem> datesListCopy = datesList;
    DateTime first = DateFormat('dd-MMM-yyyy').parse(datesList[0].dateId).subtract(const Duration(days: 1));
    String firstFormattedDate = DateFormat('dd-MMM-yyyy').format(first);
    CalendarItem newDate = CalendarItem(
        getWeekday(first.weekday), first.day.toString(), firstFormattedDate);
    datesListCopy.removeAt(6);
    datesListCopy.insert(0, newDate);

    setState(() {
      datesList = datesListCopy;
    });
  }

  void changeSelected(int newIndex) {
    String dateIdSelected = datesList[newIndex].dateId;
    onChanged(dateIdSelected);
    setState(() {
      selectedIndex = newIndex;
    });
  }

  String getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return "Lun";
      case 2:
        return "Mar";
      case 3:
        return "Mier";
      case 4:
        return "Jue";
      case 5:
        return "Vier";
      case 6:
        return "Sáb";
    }
    return "Dom";
  }
}
