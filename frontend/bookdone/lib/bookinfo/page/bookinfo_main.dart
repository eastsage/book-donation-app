import 'package:bookdone/bookinfo/model/book_comment.dart';
import 'package:bookdone/bookinfo/widgets/comment_card.dart';
import 'package:bookdone/bookinfo/widgets/comment_input.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookinfoMain extends HookConsumerWidget {
  const BookinfoMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 10),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                FutureBuilder(
                  future: restClient.getDetailBook('isbn'), // TODO: 수정
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data == null) {
                      return SizedBox.shrink();
                    }

                    final book = snapshot.data!.data;

                    return Column(
                      children: [
                        CachedNetworkImage(
                          width: 200,
                          imageUrl: book.titleUrl,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),

                        // Image(
                        //   image: AssetImage("assets/images/samplebookcover.jpg"),
                        //   width: 200,
                        // ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          book.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(thickness: 1, height: 1),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "책 정보",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              book.author,
                            ),
                            Text(
                              book.publisher,
                            ),
                            Text(
                              "발행일",
                            ),
                            Text(
                              "기타 설명",
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Divider(thickness: 1, height: 1),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.pushNamed('bookinfodetail');
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  //모서리를 둥글게
                                  borderRadius: BorderRadius.circular(15)),
                              fixedSize: Size(110, 40),
                              textStyle: const TextStyle(fontSize: 15),
                              backgroundColor: Colors.brown[300],
                              foregroundColor: Colors.white),
                          child: Text(
                            "찾아보기",
                            style: TextStyle(fontFamily: "SCDream4"),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  },
                ),
                Divider(thickness: 1, height: 1),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "댓글",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                CommentInput(),
                FutureBuilder(
                  future: restClient.getCommentsList('isbn'),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data == null) {
                      return SizedBox.shrink();
                    }

                    final commentlist = snapshot.data!.data;

                    return Expanded(
                      child: ListView.builder(
                        itemCount: commentlist.length,
                        itemBuilder: (_, index) {
                          return CommentCard(comment: commentlist[index]);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}