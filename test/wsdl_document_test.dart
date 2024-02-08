import 'package:dart_soap/dart_soap.dart';
import 'package:dart_soap/src/wsdl_document.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart' as xml;

void main() {
  // group('Test the WSDL document parsing', () {
  //   Awesome awesome;

  //   setUp(() {
  //     awesome = Awesome();
  //   });

  //   test('First Test', () {
  //     expect(awesome.isAwesome, isTrue);
  //   });
  // });

  group('Test the WSDL document parsing', () {
    test('Parses a complex type', () {
      final wsdlContent = '''
        <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
          <xs:element name="ExampleElement">
            <xs:complexType>
              <xs:sequence>
                <xs:element name="Name" type="xs:string"/>
                <xs:element name="Age" type="xs:int"/>
              </xs:sequence>
            </xs:complexType>
          </xs:element>
        </xs:schema>
      ''';

      final complexTypeElement = xml.XmlDocument.parse(wsdlContent)
          .rootElement
          .findElements('complexType')
          .first;
      final wsdlComplexType =
          WsdlComplexType.fromXmlElement(complexTypeElement);

      // print('Complex Type Name: ${wsdlComplexType.name}');
      expect(wsdlComplexType.name, 'ExampleElement');
      // print('Child Elements:');
      expect(wsdlComplexType.elements[0].name, 'Name');
      expect(wsdlComplexType.elements[1].name, 'Age');

      // for (var element in wsdlComplexType.elements) {
      //   print('  - ${element.name} (${element.type})');
      // }
      // expect(awesome.isAwesome, isTrue);
    });
  });
}
