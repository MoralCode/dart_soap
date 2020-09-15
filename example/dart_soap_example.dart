import 'package:dart_soap/dart_soap.dart';

void main() {
  var setting = <String, String>{
    'url': 'https://.../b2b/Service.asmx',
    'init': 'web',
    'root': 'soapenv',
    'Envelope':
        'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://.../webservices/"',
    'soapAction': 'http://.../webservices/'
  };

  var request = SoapRequest(
      method: 'GET_Profiles',
      parameters: {'User': '...', 'Password': '....'},
      pathResponse:
          'soap:Envelope/soap:Body/GET_UserProfileResponse/GET_UserProfileResult/up');

  var soap = Soap(setting);
  soap.postHttp(request).then((value) => {print(value)});
}
