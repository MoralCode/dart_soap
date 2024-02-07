import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class WsdlParser {
  final String wsdlUrl;

  WsdlParser(this.wsdlUrl);

  xml.XmlDocument? _cachedWSDLDocument;

  Future<xml.XmlDocument> get wsdlDocument async {
    // If the value is already cached, return it immediately
    if (_cachedWSDLDocument != null) {
      return _cachedWSDLDocument!;
    }

    // Fetch the value asynchronously
    final fetchedValue =
        await fetchWsdl().then((value) => xml.XmlDocument.parse(value));

    // Cache the fetched value
    _cachedWSDLDocument = fetchedValue;

    // Return the fetched value
    return fetchedValue;
  }

  Future<String> fetchWsdl() async {
    final response = await http.get(Uri.parse(wsdlUrl));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to fetch WSDL file. Status code: ${response.statusCode}');
    }
  }

  List<String> extractOperations(String wsdlContent) {
    final document = xml.XmlDocument.parse(wsdlContent);
    final operations = <String>[];

    for (var portTypeElement in document.findAllElements('portType')) {
      for (var operationElement in portTypeElement.findElements('operation')) {
        final operationName = operationElement.getAttribute('name');
        if (operationName != null) {
          operations.add(operationName);
        }
      }
    }

    return operations;
  }

  String? parseSoapUrl() {
    final document = xml.XmlDocument.parse(wsdlContent);

    final soapAddressElement = document.findAllElements('soap:address').first;
    return soapAddressElement.getAttribute('location');
  }

  Future<String> getSoapUrl() async {
    try {
      return parseSoapUrl();
    } catch (e) {
      throw Exception('Error reading or parsing the WSDL file: $e');
    }
  }
}

