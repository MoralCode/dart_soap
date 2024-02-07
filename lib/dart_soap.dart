library dart_soap;

import 'package:dart_soap/src/wsdl_parser.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class SoapClient {
  final WsdlParser wsdl;

  String _cachedSOAPEndpoint = '';

  Future<String> get soapEndpoint async {
    // If the value is already cached, return it immediately
    if (_cachedSOAPEndpoint.isNotEmpty) {
      return _cachedSOAPEndpoint;
    }

    // Fetch the value asynchronously
    final fetchedValue = await wsdl.getSoapUrl();

    // Cache the fetched value
    _cachedSOAPEndpoint = fetchedValue;

    // Return the fetched value
    return fetchedValue;
  }

  SoapClient(String wsdlEndpoint) : wsdl = WsdlParser(wsdlEndpoint);

  Future<String> callWebService(
      String methodName, Map<String, dynamic> parameters) async {
    final soapEnvelope = _buildSoapEnvelope(methodName, parameters);
    final response = await http.post(
      Uri.parse(await soapEndpoint),
      headers: {
        'Content-Type': 'text/xml',
      },
      body: soapEnvelope,
    );

    if (response.statusCode == 200) {
      return _parseSoapResponse(response.body);
    } else {
      throw Exception(
          'Failed to call the web service. Status code: ${response.statusCode}');
    }
  }

  String _buildSoapEnvelope(
      String methodName, Map<String, dynamic> parameters) {
    // Customize this method to construct the SOAP envelope based on the WSDL of your web service.
    // This is a simplified example.
    final envelope = xml.XmlBuilder();
    envelope.element('soapenv:Envelope',
        namespace: 'http://schemas.xmlsoap.org/soap/envelope/', nest: () {
      envelope.namespace(
          'soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
      envelope.namespace('web', 'http://www.example.com/webservice');

      envelope.element('soapenv:Header', nest: () {});
      envelope.element('soapenv:Body', nest: () {
        envelope.element('web:$methodName', nest: () {
          for (var entry in parameters.entries) {
            envelope.element(entry.key, nest: entry.value.toString());
          }
        });
      });
    });

    return envelope.buildDocument().toXmlString(pretty: true);
  }

  String _parseSoapResponse(String response) {
    // Customize this method to parse the SOAP response.
    // This is a simplified example.
    final document = xml.XmlDocument.parse(response);
    final result = document.findAllElements('YourResultElementName').first.text;
    return result;
  }
}
