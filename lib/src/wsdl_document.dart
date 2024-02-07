import 'package:xml/xml.dart' as xml;

class WsdlDocument {
  final String serviceName;
  final List<WsdlOperation> operations;
  final List<WsdlType> types;

  WsdlDocument(
      {required this.serviceName,
      required this.operations,
      required this.types});

  factory WsdlDocument.fromXml(String xmlContent) {
    final document = xml.XmlDocument.parse(xmlContent);

    final serviceName = document
        .findAllElements('service', namespace: '*')
        .first
        .getAttribute('name')!;

    final operations = document
        .findAllElements('operation', namespace: '*')
        .map((operationElement) =>
            WsdlOperation.fromXmlElement(operationElement))
        .toList();

    final types = document
        .findAllElements('types', namespace: '*')
        .map((typesElement) => WsdlType.fromXmlElement(typesElement))
        .toList();

    return WsdlDocument(
        serviceName: serviceName, operations: operations, types: types);
  }
}

class WsdlOperation {
  final String name;
  final String inputMessage;
  final String outputMessage;

  WsdlOperation(
      {required this.name,
      required this.inputMessage,
      required this.outputMessage});

  factory WsdlOperation.fromXmlElement(xml.XmlElement element) {
    final name = element.getAttribute('name')!;
    final inputMessage = element
        .findElements('input', namespace: '*')
        .first
        .getAttribute('message')!;
    final outputMessage = element
        .findElements('output', namespace: '*')
        .first
        .getAttribute('message')!;

    return WsdlOperation(
        name: name, inputMessage: inputMessage, outputMessage: outputMessage);
  }
}

class WsdlType {
  final String name;
  final List<WsdlElement> elements;

  WsdlType({required this.name, required this.elements});

  factory WsdlType.fromXmlElement(xml.XmlElement element) {
    final name = element.getAttribute('name')!;
    final elements = element
        .findAllElements('element', namespace: '*')
        .map((elementElement) => WsdlElement.fromXmlElement(elementElement))
        .toList();

    return WsdlType(name: name, elements: elements);
  }
}

class WsdlElement {
  final String name;
  final String type;

  WsdlElement({required this.name, required this.type});

  factory WsdlElement.fromXmlElement(xml.XmlElement element) {
    final name = element.getAttribute('name')!;
    final type = element.getAttribute('type')!;

    return WsdlElement(name: name, type: type);
  }
}
