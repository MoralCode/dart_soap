A library for Dart developers.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:dart_soap/dart_soap.dart';

main() {
  var awesome = new Awesome();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme



 void main(List<String> args) {

   var setting = <String,String>{
     'url':'https://.../b2b/Service.asmx',
     'init': 'web',
     'root': 'soapenv',
     'Envelope': 'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://.../webservices/"',
     'SOAPAction':'http://.../webservices/'
   };

   var request = SoapRequest();
   request.method = 'GET_Drivers';
   request.parameters = {
     'User':'...',
     'Password':'...',
     'FleetId':'...',
     'DrvId':'0'
   };

   var soap = Soap(setting);
   soap.getHttp(request).then((value) => {
      print(value['soap:Envelope']['soap:Body'])
   });
   
 }