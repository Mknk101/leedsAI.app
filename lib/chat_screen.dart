import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:chat_bubbles/chat_bubbles.dart';
import 'message.dart';
import "dart:convert";
import 'dart:js';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LeedsAI",
          style: TextStyle(color: Colors.white, fontSize: 17,),
        ),
        centerTitle: false,
        backgroundColor: Colors.black87,
        elevation: 0.0,
        actions:  const [
          Padding(
            padding: EdgeInsets.fromLTRB(0,0,8.0,0),
            child: IconButton(
              onPressed: null,
              icon: Icon(Icons.menu, color: Colors.white,),

            ),
          ),
        ],
      ),


      body:

      Column(
        children: [

          Container(
            margin: const EdgeInsets.fromLTRB(14,37.0,0,0),
            child: const Text(
              "Disclaimer: MediBot has a high diagnoses accuracy, but should be used in tandem with a certified medical practitioner in advanced issues.",
              style : TextStyle(
                color: Colors.black54,
                fontSize: 15,),
            ),
          ),

          Container(
            margin: const EdgeInsets.fromLTRB(14,18.0,0,10),
            child: const Text(
              "Click here to make a donation to MediBot and help support research and performance-boosting." ,
              style : TextStyle(fontSize: 12,),
            ),
          ),

          const Divider(thickness: 1,),

          Expanded(
            child: ListView.builder(
                controller: scrollController,
                itemCount: msgs.length,
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (context, index) {

                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: isTyping && index == 0
                          ? Column(
                        children: [
                          BubbleNormal(
                            text: msgs[0].msg,
                            isSender: true,
                            color: Colors.lightGreenAccent,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 16, top: 4),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Typing...")),
                          )
                        ],
                      )
                          : BubbleNormal(
                        text: msgs[index].msg,
                        isSender: msgs[index].isSender,
                        color: msgs[index].isSender
                            ? Colors.lightGreenAccent
                            : Colors.grey.shade200,
                      ));
                }),
          ),




          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (value) {
                          sendMsg();
                        },
                        textInputAction: TextInputAction.send,
                        showCursor: true,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: "Enter text"),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  sendMsg();
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              )
            ],
          ),

        ],

      ),



      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(0,0,0,50),
        child: const FloatingActionButton(
          onPressed: null,
          elevation: 0,
          backgroundColor: Colors.indigo,
          child: Text("theme"),
        ),
      ),

    );
  }

  void sendMsg() async {
    String text = controller.text;
    String apiKey = "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";
    controller.clear();
    try {
      if (text.isNotEmpty) {
        setState(() {
          msgs.insert(0, Message(true, text));
          isTyping = true;
        });
        scrollController.animateTo(0.0,
            duration: const Duration(seconds: 1), curve: Curves.easeOut);
        var response = await http.post(
            Uri.parse("https://api.openai.com/v1/chat/completions"),
            headers: {
              "Authorization": "Bearer $apiKey",
              "Content-Type": "application/json"
            },
            body: jsonEncode({
              "model": "gpt-3.5-turbo",
              "messages": [
                {"role": "user", "content": text}
              ]
            }));
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          setState(() {
            isTyping = false;
            msgs.insert(
                0,
                Message(
                    false,
                    json["choices"][0]["message"]["content"]
                        .toString()
                        .trimLeft()));
          });
          scrollController.animateTo(0.0,
              duration: const Duration(seconds: 1), curve: Curves.easeOut);
        }
      }
    } on Exception {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
          content: Text("Some error occurred, please try again!")));
    }
  }



  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Message> msgs = [];
  bool isTyping = false;


}







