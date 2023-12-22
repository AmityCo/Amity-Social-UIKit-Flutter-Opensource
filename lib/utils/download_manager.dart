import 'dart:io';
import 'package:file_picker/file_picker.dart';
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

    print("File saved to $filePath");
  } catch (e) {
    print("An error occurred while downloading or saving the file: $e");
  }
}

Future<void> openFileFromUrl(String url) async {
  try {
    // Getting the app's directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/temp_file';

    // Downloading the file
    final response = await http.get(Uri.parse(url));
    print(url);
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    // Open the file
    OpenFile.open(filePath);
  } catch (e) {
    print("An error occurred while downloading or opening the file: $e");
  }
}

Future<void> launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    print("launching...: ${url}");
    await launchURL(url);
  } else {
    throw 'Could not launch $url';
  }
}
