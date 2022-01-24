//import 'dart:html';

import 'dart:async';
import 'dart:developer';
//import 'dart:html';
//import 'dart:html';

import 'package:flutter/material.dart';
//import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:location/location.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

void main() => runApp(StartProgramm());

class StartProgramm extends StatefulWidget {
  @override
  MyApp createState() => MyApp();
  
}

class MyApp extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
          splash: Image.asset(
            'assets/animation.gif',
          ),
          // nextScreen: YellowBird(),
          nextScreen: WebviewWindow(),
          splashTransition: SplashTransition.slideTransition,
        ),
      );
    }
}

class WebviewWindowSecond extends StatefulWidget {
  @override
  MainScreenSecond createState() => MainScreenSecond();
}


class MainScreenSecond extends State<StatefulWidget> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _webController;
  
  Location location = new Location();
  late bool _isSeviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool _isListenLocation = false, _isGetLocation = false;
  String cookieString = "cookie_name=cookie_value; path=/";
  String url = "http://212.80.206.193/test.project-270.com/mob/public/register";
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: WebView(
                userAgent: "Android",
                              
                initialUrl: url,
                javascriptMode: JavascriptMode.unrestricted,

                debuggingEnabled: true,
                
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                  
                  setState(() {
                    _webController = webViewController;
                    
                  });
                      
                
                },
                onPageFinished: (String url) async {
                  if (url.startsWith("https://israelpost.co.il/%D7%A9%D7%99%D7%A8%D7%95%D7%AA%D7%99%D7%9D/%D7%90%D7%99%D7%AA%D7%95%D7%A8-%D7%9E%D7%99%D7%A7%D7%95%D7%93/")) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Index()));
                  }

                      _isSeviceEnabled = await location.serviceEnabled();
                  if(!_isSeviceEnabled){
                    _isSeviceEnabled = await location.requestService();
                    if (_isSeviceEnabled) return;
                  }
                  _permissionGranted = await location.hasPermission();
                  if(_permissionGranted == PermissionStatus.denied){
                    _permissionGranted = await location.requestPermission();
                    if (_permissionGranted != PermissionStatus.granted) return;
                  }
                  _locationData = await location.getLocation();
                  setState(() {
                      _isGetLocation = true;
                  });
                  
                  await _webController.evaluateJavascript("document.getElementById('latitude_mobile').value = '${_locationData.latitude}';document.getElementById('longitude_mobile').value = '${_locationData.longitude}';",);
                },
                
                navigationDelegate: (NavigationRequest request) {
                 
                  if (request.url.contains("geo:")) {
                    launch(request.url);
                    return NavigationDecision.prevent;
                  } else {
                  return NavigationDecision.navigate;
                  }
                },
              ),
              
            ),
          ],
        ),

      ),
    );
  }
}


class Index extends StatefulWidget {
  @override
  IndexScreen createState() => IndexScreen();
}

class IndexScreen extends State<StatefulWidget> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _webController;
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: "https://israelpost.co.il/%D7%A9%D7%99%D7%A8%D7%95%D7%AA%D7%99%D7%9D/%D7%90%D7%99%D7%AA%D7%95%D7%A8-%D7%9E%D7%99%D7%A7%D7%95%D7%93/",
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
          setState(() {
            _webController = webViewController;
          });
        },
      ),
      floatingActionButton: FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context, 
          AsyncSnapshot<WebViewController> controller) {
            if (controller.hasData) {
              return FloatingActionButton(
                child: Icon(Icons.arrow_back),
                backgroundColor: Colors.orange,
                onPressed: () async{
                  //controller.data.goBack();
                  var currentUrl = await _webController.currentUrl();
                  log('$currentUrl');
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => WebviewWindowSecond()));
                  // _webController.reload();
                  // _webController.loadUrl('http://212.80.206.193/test.project-270.com/mob/public/register');
                });
            }

            return Container();
          }
        ),
    );
  }
}

class WebviewWindow extends StatefulWidget {
  @override
  MainScreen createState() => MainScreen();
}


class MainScreen extends State<StatefulWidget> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _webController;
  
  Location location = new Location();
  late bool _isSeviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool _isListenLocation = false, _isGetLocation = false;
  String cookieString = "cookie_name=cookie_value; path=/";
  String url = "http://212.80.206.193/test.project-270.com/mob/public";
  final cookieManager = WebviewCookieManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: WebView(
                userAgent: "Android",
                              
                initialUrl: url,
                 javascriptMode: JavascriptMode.unrestricted,

                debuggingEnabled: true,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                  setState(() {
                    _webController = webViewController;
                  });
                      
                },
                
                onPageFinished: (String url) async {
                  final gotCookies = await cookieManager.getCookies(url);
            for (var item in gotCookies) {
              log('$item');
            }
                  if (url.startsWith("https://israelpost.co.il/%D7%A9%D7%99%D7%A8%D7%95%D7%AA%D7%99%D7%9D/%D7%90%D7%99%D7%AA%D7%95%D7%A8-%D7%9E%D7%99%D7%A7%D7%95%D7%93/")) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Index()));
                  }

                      _isSeviceEnabled = await location.serviceEnabled();
                  if(!_isSeviceEnabled){
                    _isSeviceEnabled = await location.requestService();
                    if (_isSeviceEnabled) return;
                  }
                  _permissionGranted = await location.hasPermission();
                  if(_permissionGranted == PermissionStatus.denied){
                    _permissionGranted = await location.requestPermission();
                    if (_permissionGranted != PermissionStatus.granted) return;
                  }
                  _locationData = await location.getLocation();
                  setState(() {
                      _isGetLocation = true;
                  });
                  
                  await _webController.evaluateJavascript("document.getElementById('latitude_mobile').value = '${_locationData.latitude}';document.getElementById('longitude_mobile').value = '${_locationData.longitude}';",);
                },
                
                navigationDelegate: (NavigationRequest request) {
                 
                  if (request.url.contains("geo:")) {
                    launch(request.url);
                    return NavigationDecision.prevent;
                  } else {
                  return NavigationDecision.navigate;
                  }
                },
              ),
              
            ),
          ],
        ),

      ),
    );
  }
}

class YellowBird extends StatefulWidget {
  @override
  MainLocation createState() => MainLocation();
}

class MainLocation extends State<StatefulWidget> {
  Location location = new Location();
  late bool _isSeviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool _isListenLocation = false, _isGetLocation = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () async{
              _isSeviceEnabled = await location.serviceEnabled();
              if(!_isSeviceEnabled){
                _isSeviceEnabled = await location.requestService();
                if (_isSeviceEnabled) return;
              }

              _permissionGranted = await location.hasPermission();
              if(_permissionGranted == PermissionStatus.denied){
                _permissionGranted = await location.requestPermission();
                if (_permissionGranted != PermissionStatus.granted) return;
              }
              _locationData = await location.getLocation();
              setState(() {
                  _isGetLocation = true;
              });
            }, child: Text('Get Location')),
            _isGetLocation ? Text('Location: ${_locationData.latitude} ${_locationData.longitude}') : Container(),
            ElevatedButton(onPressed: () async{Navigator.of(context).push(MaterialPageRoute(builder: (context) => WebviewWindow()));}, child: Text('Proceed')),
          ],
        ),
      ),
    );  
  }
}

