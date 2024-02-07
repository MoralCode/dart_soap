library dart_soap;

import 'package:dart_soap/src/wsdl_parser.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class SoapClient {
  final WsdlParser wsdl;
  bool debug;

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

  SoapClient(String wsdlEndpoint, {this.debug = false})
      : wsdl = WsdlParser(wsdlEndpoint);

  Future<String> callWebService(
      String methodName, Map<String, dynamic> parameters) async {
    final soapEnvelope = _buildSoapEnvelope(methodName, parameters);
    if (debug) {
      print('SOAP Envelope being sent: $soapEnvelope');
    }
    final response = await http.post(
      Uri.parse(await soapEndpoint),
      headers: {
        'Content-Type': 'text/xml',
      },
      body: soapEnvelope,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to call the web service. Status code: ${response.statusCode}');
    }

    try {
      return _parseSoapResponse(response.body, methodName)
          .then((value) => value.value!);
    } catch (e) {
      throw Exception(
          'Failed to parse the response from the web service. Error: $e');
    }
  }

  String _buildSoapEnvelope(
      String methodName, Map<String, dynamic> parameters) {
    // Customize this method to construct the SOAP envelope based on the WSDL of your web service.
    // This is a simplified example.
    final envelope = xml.XmlBuilder();
    envelope.element('soapenv:Envelope', namespaces: <String, String>{
      'tns': 'http://schemas.xmlsoap.org/soap/envelope/',
    }, nest: () {
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

  Future<xml.XmlElement> _parseSoapResponse(
      String response, String methodName) async {
    // Customize this method to parse the SOAP response.
    // This is a simplified example.
    if (debug) {
      print('SOAP Response being received: $response');
    }
    final response_document = xml.XmlDocument.parse(response);
    final response_element_name =
        await wsdl.parseResponseDataElement(methodName);
    final dataElement = response_document
        .findAllElements(response_element_name) //, namespace: namespaces['web']
        .first;

    return dataElement;
  }
}
