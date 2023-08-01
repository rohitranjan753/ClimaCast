import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/detail_page.dart';
import 'package:weatherapp/models/city.dart';
import 'package:weatherapp/models/constants.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/widgets/weather_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Constants myConstants = Constants();

  //initialization
  int temperature=0;
  int maxTemp=0;
  String weatherStateName = 'Loading..';
  int humidity=0;
  int windSpeed = 0;

  var currentDate = 'Loading..';
  String imageUrl = '';
  int woeid= 44418; //Id of london
  String location = 'London';//default city

  //get the cities and selected cities data
  var selectedCities = City.getSelectedCities();
  List<String> cities = ['London']; // the list ot hold our selected cities: Default is london
  List consolidatedWeatherList=[];// to hold our weather data after api call

  String apiKey = '2d60b8a199f8462fb5361037230108&q=';
  String baseUrl = 'http://api.weatherapi.com/v1/current.json?key=2d60b8a199f8462fb5361037230108&q=';
  String totalUrl = 'http://api.weatherapi.com/v1/current.json?key=2d60b8a199f8462fb5361037230108&q=';

  //get the where on earth id
  void fetchLocation(String location) async{
    var searchResult = await http.get(Uri.parse(totalUrl+location));
    var result = json.decode(searchResult.body);

      setState(() {
        woeid = result['woeid'];
      });
    fetchWeatherData(); // Fetch weather data after getting the woeid

  }

  void fetchWeatherData() async {
    var weatherResult = await http.get(Uri.parse(totalUrl + woeid.toString()));
    var result = json.decode(weatherResult.body);
    var currentWeather = result['current'];

    setState(() {


      temperature = currentWeather['temp_c'].round();
      weatherStateName = currentWeather['condition']['text'];
      humidity = currentWeather['humidity'];
      windSpeed = currentWeather['wind_kph'].round();
      maxTemp = currentWeather['feelslike_c'].round();

      //date formatting
      var myDate = DateTime.fromMillisecondsSinceEpoch(
          currentWeather['last_updated_epoch'] * 1000);
      currentDate = DateFormat('EEEE, d MMMM').format(myDate);

      //set the image url
      imageUrl = currentWeather['condition']['icon']
          .replaceAll('//', 'https://');  //remove any spaces in the weather state name

    });
  }

  @override
  void initState() {
    fetchLocation(cities[0]);
    fetchWeatherData();

    //For all the selected cities from our City model, extract the city and add it to our original cities list
    for (int i = 0; i < selectedCities.length; i++) {
      cities.add(selectedCities[i].city);
    }
    super.initState();
  }

  //Create a shader linear gradient
  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffABCFF2), Color(0xff9AC6F3)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));



  @override
  Widget build(BuildContext context) {
    //Create a size variable for the mdeia query
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Our profile image
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.asset(
                  'assets/profile.png',
                  width: 40,
                  height: 40,
                ),
              ),
              //our location dropdown
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/pin.png',
                    width: 20,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton(
                        value: location,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: cities.map((String location) {
                          return DropdownMenuItem(
                              value: location, child: Text(location));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            location = newValue!;
                            fetchLocation(location);
                            fetchWeatherData();
                          });
                        }),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
            Text(
              currentDate,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              width: size.width,
              height: 200,
              decoration: BoxDecoration(
                  color: myConstants.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: myConstants.primaryColor.withOpacity(.5),
                      offset: const Offset(0, 25),
                      blurRadius: 10,
                      spreadRadius: -12,
                    )
                  ]),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40,
                    left: 20,
                    child: imageUrl == ''
                        ? const Text('')
                        : Image.network(imageUrl,width: 150,)
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: Text(
                      weatherStateName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            temperature.toString(),
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = linearGradient,
                            ),
                          ),
                        ),
                        Text(
                          'o',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = linearGradient,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  weatherItem(
                    text: 'Wind Speed',
                    value: windSpeed,
                    unit: 'km/h',
                    imageUrl: 'assets/windspeed.png',
                  ),
                  weatherItem(
                      text: 'Humidity',
                      value: humidity,
                      unit: '',
                      imageUrl: 'assets/humidity.png'),
                  weatherItem(
                    text: 'Wind Speed',
                    value: maxTemp,
                    unit: 'C',
                    imageUrl: 'assets/max-temp.png',
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Next 7 Days',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: myConstants.primaryColor),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: consolidatedWeatherList.length,
                    itemBuilder: (BuildContext context, int index) {
                      String today = DateTime.now().toString().substring(0, 10);
                      var selectedDay =
                      consolidatedWeatherList[index]['applicable_date'];
                      var futureWeatherName =
                      consolidatedWeatherList[index]['weather_state_name'];
                      var weatherUrl =
                      futureWeatherName.replaceAll(' ', '').toLowerCase();

                      var parsedDate = DateTime.parse(
                          consolidatedWeatherList[index]['applicable_date']);
                      var newDate = DateFormat('EEEE')
                          .format(parsedDate)
                          .substring(0, 3); //formateed date

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(consolidatedWeatherList: consolidatedWeatherList, selectedId: index, location: location,)));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          margin: const EdgeInsets.only(
                              right: 20, bottom: 10, top: 10),
                          width: 80,
                          decoration: BoxDecoration(
                              color: selectedDay == today
                                  ? myConstants.primaryColor
                                  : Colors.white,
                              borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 5,
                                  color: selectedDay == today
                                      ? myConstants.primaryColor
                                      : Colors.black54.withOpacity(.2),
                                ),
                              ]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                consolidatedWeatherList[index]['the_temp']
                                    .round()
                                    .toString() +
                                    "C",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: selectedDay == today
                                      ? Colors.white
                                      : myConstants.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Image.asset(
                                'assets/' + weatherUrl + '.png',
                                width: 30,
                              ),
                              Text(
                                newDate,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: selectedDay == today
                                      ? Colors.white
                                      : myConstants.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
