import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class WsdlParser {
  final String wsdlUrl;

  WsdlParser(this.wsdlUrl);

  // getter for caching WSDLContent

  String get wsdlContent => "";

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

void main() async {
  final wsdlParser = WsdlParser('http://www.example.com/your-service.wsdl');

  try {
    final soapUrl = await wsdlParser.getSoapUrl();
    print('SOAP URL: $soapUrl');
  } catch (e) {
    print('Error: $e');
  }
}
