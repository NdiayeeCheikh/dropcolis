import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({super.key});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  late var url;
  var urlController = TextEditingController();
  var initialUrl = 'https://dropcolis.ca/livraison/home/';
  var isLoading = false;

  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController!.canGoBack()) {
      webViewController!.goBack();
      return Future.value(false);
    } else {
      SystemNavigator.pop();
      return Future.value(true);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pullToRefreshController = PullToRefreshController(
      onRefresh: () {
        webViewController!.reload();
      },
      options: PullToRefreshOptions(
        color: Colors.red,
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<ConnectivityResult>(
        stream: Connectivity().onConnectivityChanged,
        builder: (context, AsyncSnapshot<ConnectivityResult> snapshot) {
          if (snapshot.hasData) {
            ConnectivityResult result = snapshot.data!;
            if (result == ConnectivityResult.mobile ||
                result == ConnectivityResult.wifi) {
              return WillPopScope(
                onWillPop: () => _goBack(context),
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            InAppWebView(
                              onLoadStart: (controller, url) {
                                setState(() {
                                  isLoading = true;
                                });
                              },
                              onLoadStop: (controller, url) {
                                pullToRefreshController!.endRefreshing();
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              onProgressChanged: (controller, progress) {
                                setState(() {
                                  if (progress == 100) {
                                    pullToRefreshController!.endRefreshing();
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                });
                              },
                              pullToRefreshController: pullToRefreshController,
                              onWebViewCreated: (controller) =>
                                  webViewController = controller,
                              initialUrlRequest: URLRequest(
                                url: Uri.parse(
                                  initialUrl,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: isLoading,
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset('assets/NoInternet.png'),
                    ),
                    Center(
                      child: const Text(
                        'Veuillez vérifier votre connexion Internet !',
                        style: TextStyle(
                          fontSize: 26.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset('assets/NoInternet.png'),
                  ),
                  Center(
                    child: const Text(
                      'Veuillez vérifier votre connexion Internet !',
                      style: TextStyle(
                        fontSize: 26.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
