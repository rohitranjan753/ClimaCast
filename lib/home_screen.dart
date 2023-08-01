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
      location = result;
    });
    fetchWeatherData(); // Fetch weather data after getting the woeid

  }

  void fetchWeatherData() async {
    var weatherResult = await http.get(Uri.parse(totalUrl + location.toString()));
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

  // Create a list to hold the 2-hour forecast data
  List<dynamic> twoHourForecast = [];

  // Fetch the 2-hour forecast data from the API
  void fetchTwoHourForecast(location) async {
    var forecastResult = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=2d60b8a199f8462fb5361037230108&q=$location'));
    var result = json.decode(forecastResult.body);
    var forecastDay = result['forecast']['forecastday'];
    print(forecastDay);
    if (forecastDay.isNotEmpty) {
      twoHourForecast = forecastDay[0]['hour'];
      print(twoHourForecast);
    }
  }


  @override
  void initState() {
    fetchLocation(cities[0]);
    fetchWeatherData();
    fetchTwoHourForecast(location);

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
                            fetchTwoHourForecast(location);
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
                itemCount: twoHourForecast.length,
                itemBuilder: (BuildContext context, int index) {
                  var hourForecast = twoHourForecast[index];

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('h:mm a').format(DateTime.parse(hourForecast['time'])),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.network(hourForecast['condition']['icon'].replaceAll('//', 'https://')),
                        const SizedBox(height: 8),
                        Text(
                          '${hourForecast['temp_c'].round()}°C',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
