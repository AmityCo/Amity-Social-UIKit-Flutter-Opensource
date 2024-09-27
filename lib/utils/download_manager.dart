import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> downloadFile(String url, String fileName) async {
  try {
    // Getting the app's directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    // Downloading the file
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
  } catch (_) {}
}

Future<void> openFileFromUrl(String url) async {
  try {
    // Getting the app's directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/temp_file';

    // Downloading the file
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    // Open the file
    OpenFile.open(filePath);
  } catch (_) {}
}

Future<void> launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchURL(url);
  } else {
    throw 'Could not launch $url';
  }
}
