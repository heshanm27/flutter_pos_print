import 'package:flutter/material.dart';

import '../model/Info_model.dart';

class InfoComponents extends StatelessWidget {
  List<InfoModel> data;
  String title;

  InfoComponents({required this.title, required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black.withOpacity(0.5),

              ),
        ),
        Divider(
          color: Colors.black.withOpacity(0.3),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              InfoModel item = data[index];
              return  ListTile(
                title: Text(item.title,style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withOpacity(0.6)
                )),
                subtitle: Text(item.value,style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500
              ))
              );
            },
          ),
        )
      ],
    );
  }
}
