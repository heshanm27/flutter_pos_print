import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class PrintingConverter extends StatelessWidget {
  final String convertedStoreData;

  const PrintingConverter({
    required this.convertedStoreData,
  });

    //   dom.Document document = htmlparser.parse(convertedStoreData);
    // RichText(text: HTML.toTextSpan(context, convertedStoreData));

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HTML Content'),
      ),
      body: SingleChildScrollView(
        child: HtmlWidget(
          convertedStoreData,
        ),
      ),
    );
  }
}
