import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';
/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}

enum ContentType{
  JSON,
  XML,
}

class SoapRequest {
  String method;
  String url;
  Map<String,String> parameters;
}


class Soap {

  var configuration = <String, String>{};
  Soap(Map<String, String> setting){
    configuration = setting;
  }

  Future<dynamic> getHttp(SoapRequest request) async {
    try{
      var baseUrl = configuration['url'];
      var response = await http.post(baseUrl, 
        headers: buildHeader(request),
        body: utf8.encode(buildBody(request)),
        encoding: Encoding.getByName('UTF-8')
      );
      return convertXMLtoJson(response.body.toString());
    }catch(e){
      print(e);
    }
  }

  Map<String, String> buildHeader(SoapRequest request){
    var header = <String,String>{};
    header['Content-Type'] = 'text/xml';
    header['SOAPAction'] = '${configuration['soapAction']}${request.method}';
    header['Host'] = '${configuration['host']}';
    return header;
  }


  String buildBody(SoapRequest request){
    var body = '';
    request.parameters.keys.forEach((key) {
      body += '<${configuration['init']}:${key}>${request.parameters[key]}</${configuration['init']}:${key}>\n';
    });
    var soap = 
    ''' <${configuration['root']}:Envelope ${configuration['Envelope']}>
          <${configuration['root']}:Header/>
          <${configuration['root']}:Body>
            <${configuration['init']}:${request.method}>
              ${body}
            </${configuration['init']}:${request.method}>
          </${configuration['root']}:Body>
        </${configuration['root']}:Envelope>
    ''';
    print(soap);
    return soap;
  }

  dynamic convertXMLtoJson(String xml){
    var xml2Json = Xml2Json();
    xml2Json.parse(xml);
    var jsonString = xml2Json.toParker();
    return jsonDecode(jsonString);
  }

}