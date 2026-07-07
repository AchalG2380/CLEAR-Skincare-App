import 'package:flutter/material.dart';

class InfoContainer extends StatelessWidget {
  final String title;
  final List<String> lists;

  const InfoContainer({super.key, required this.title, required this.lists});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 50, 14, 95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 79, 35, 123),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          for (var i = 0; i < lists.length; i++) ListBuild(title: lists[i]),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color.fromRGBO(140, 110, 255, 1),
            ),
          ),
        ],
      ),
    );
  }
}

class ListBuild extends StatelessWidget {
  final String title;

  const ListBuild({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: "Enter your $title",
            hintStyle: TextStyle(
              color: const Color.fromARGB(255, 177, 177, 177),
            ),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
