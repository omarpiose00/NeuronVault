// lib/widgets/markdown_renderer.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AiMarkdownRenderer extends StatelessWidget {
  final String data;
  final bool selectable;

  const AiMarkdownRenderer({
    super.key,
    required this.data,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: data,
      selectable: selectable,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        code: TextStyle(
          backgroundColor: Colors.grey.shade200,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          // Mostra un dialog invece di aprire il link
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Link"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Hai cliccato su un link: $href'),
                      const SizedBox(height: 8),
                      const Text('Non è possibile aprire i link in questa versione dell\'app.')
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }
}