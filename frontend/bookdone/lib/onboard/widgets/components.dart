import 'package:bookdone/main.dart';
import 'package:bookdone/onboard/service/login_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GetStartBtn extends StatefulWidget {
  const GetStartBtn({
    Key? key,
    required this.size,
    required this.textTheme,
  }) : super(key: key);

  final Size size;
  final TextTheme textTheme;

  @override
  State<GetStartBtn> createState() => _GetStartBtnState();
}

class _GetStartBtnState extends State<GetStartBtn> {
  bool isLoading = false;

  loadingHandler() {
    setState(() {
      isLoading = true;
      Future.delayed(const Duration(seconds: 1)).then((value) {
        isLoading = false;
        LoginApi.kakaoLogin(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loadingHandler,
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        width: widget.size.width / 1.5,
        height: widget.size.height / 13,
        decoration: BoxDecoration(
            color: Colors.brown, borderRadius: BorderRadius.circular(15)),
        child: Center(
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
              : Text("카카오로 시작하기", style: widget.textTheme.bodyLarge),
        ),
      ),
    );
  }
}

class SkipBtn extends StatelessWidget {
  const SkipBtn({
    Key? key,
    required this.size,
    required this.textTheme,
    required this.onTap,
  }) : super(key: key);

  final Size size;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      width: size.width / 1.5,
      height: size.height / 13,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.brown,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: onTap,
        splashColor: Colors.brown,
        child: Center(
          child: Text("Skip", style: textTheme.bodyLarge),
        ),
      ),
    );
  }
}