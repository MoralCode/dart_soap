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

  Future<List<String>> extractOperations() async {
    final document = await wsdlDocument;
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

  Future<String> parseResponseDataElement(String operationName) async {
    final document = await wsdlDocument;
    final operationElement = document
        .findAllElements('operation', namespace: '*')
        .firstWhere((element) => element.getAttribute('name') == operationName);

    final outputElementName =
        operationElement.findElements('output').first.getAttribute('message');
    final responseDataElementName = document
        .findAllElements('message')
        .firstWhere(
            (element) => element.getAttribute('name') == outputElementName)
        .findAllElements('part')
        .first
        .getAttribute('name');
    if (responseDataElementName != null) {
      return responseDataElementName;
    } else {
      throw Exception('Operation "$operationName" not found in the WSDL file.');
    }
  }

  Future<String?> parseSoapUrl() async {
    final document = await wsdlDocument;

    final soapAddressElement = document.findAllElements('soap:address').first;
    return soapAddressElement.getAttribute('location');
  }

  //TODO: parseSoapURLs for handling multiple urls

  // Future<String> getSoapUrl() async {
  //   try {
  //     return parseSoapUrl();
  //   } catch (e) {
  //     throw Exception('Error reading or parsing the WSDL file: $e');
  //   }
  // }
}
