import 'package:flutter/material.dart';

class ExchangeDialog extends StatelessWidget {
  final String exchangeDetails;
  final String imageUrl;

  const ExchangeDialog(
      {Key? key, required this.exchangeDetails, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exchange Details'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
                imageUrl.isNotEmpty ? Image.network(imageUrl) : Container(),
              ] +
              exchangeDetails.split('\n').map((item) {
                var splitItem = item.split(':');
                if (splitItem.length == 2) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                              text: '${splitItem[0]}: ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          TextSpan(
                              text: splitItem[1],
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: Text(item),
                  );
                }
              }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
