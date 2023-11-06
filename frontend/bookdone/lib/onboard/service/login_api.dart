import 'package:bookdone/app.dart';
import 'package:bookdone/main.dart';
import 'package:bookdone/onboard/model/user_res.dart';
import 'package:bookdone/onboard/page/add_additional_info.dart';
import 'package:bookdone/onboard/repository/user_repository.dart';
import 'package:bookdone/router/router_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginApi {
  static String baseURL = dotenv.get('API_URL');

  static Future<void> kakaoLogin(BuildContext context) async {
    if (await isKakaoTalkInstalled()) {
      debugPrint('카톡으루로그잉');
      try {
        await UserApi.instance.loginWithKakaoTalk();
        debugPrint('카카오톡으로 로그인 성공');
        if (await checkHasToken()) {
          var token = await TokenManagerProvider.instance.manager.getToken();
          debugPrint('토큰냠냠 ${token!.accessToken}');
          debugPrint('${token.toJson()}');
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => AddAdditionalInfo()));
          context.go(RouterPath.addAdditionalInfo);
        }
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          signup(context);
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => MyHomePage()));
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      debugPrint('계정로긍이');
      // debugPrint(await KakaoSdk.origin);
      try {
        await UserApi.instance.loginWithKakaoAccount();
        debugPrint('카카오계정으로 로그인 성공');
        if (await checkHasToken()) {
          var token = await TokenManagerProvider.instance.manager.getToken();
          debugPrint('토큰냠냠 ${token!.accessToken}');
          debugPrint('${token.toJson()}');
          signup(context);
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => AddAdditionalInfo()));
        }
      } catch (error) {
        debugPrint('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  static Future<bool> checkHasToken() async {
    if (await AuthApi.instance.hasToken()) {
      try {
        AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        debugPrint('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
        return true;
      } catch (error) {
        if (error is KakaoException && error.isInvalidTokenError()) {
          print('토큰 만료 $error');
        } else {
          print('토큰 정보 조회 실패 $error');
        }
        return false;

        // try {
        //   // 카카오계정으로 로그인
        //   OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        //   print('로그인 성공 ${token.accessToken}');
        // } catch (error) {
        //   print('로그인 실패 $error');
      }
    } else {
      print('발급된 토큰 없음');

      return false;
    }
  }

  static Future<void> signup(context) async {
    var token = await TokenManagerProvider.instance.manager.getToken();
    // AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
    // debugPrint(tokenInfo.toString());
    // debugPrint(token.toString());

    var dio = Dio();

    dio.options.headers['Authorization'] = 'Bearer ${token!.idToken}';
    debugPrint(dio.options.headers.toString());

    RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
      if (T != dynamic &&
          !(requestOptions.responseType == ResponseType.bytes ||
              requestOptions.responseType == ResponseType.stream)) {
        if (T == String) {
          requestOptions.responseType = ResponseType.plain;
        } else {
          requestOptions.responseType = ResponseType.json;
        }
      }
      return requestOptions;
    }

    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result =
        await dio.fetch<Map<String, dynamic>>(_setStreamType<UserRes>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              dio.options,
              '/api/auth',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseURL)));
    final res = UserRes.fromJson(_result.data!);
    print(res);
    UserData user = res.data;
    if (res.data.newMember == false) {
      // 여기 들어왔다는건 이미 가입된 유저인데 이번에 로그인한 유저이니까
      // pref에 저장해야 할 정보 ::
      // 닉네임
      // 책갈피 수
      // 주소 코드
      // 프로필 이미지 url
      // 현재 로그인 상태
      // accessToken
      // oauthId
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setInt('loginStatus', 1);
      await pref.setString('nickname', user.member.nickname);
      await pref.setInt('bookmarkCnt', user.member.point);
      await pref.setString('address', user.member.address);
      await pref.setString('profileImage', user.member.image);
      await pref.setString('accessToken', user.accessToken);
      await pref.setString('oauthId', user.member.oauthId);
      // TODO: accessToken secure storage로 관리하기
      // await ref.watch(userInfoRepositoryProvider).restoreUserData(user);
      // await ref.read(userInfoRepositoryProvider).restoreUserData(user);
      // 저장했으니 로그인 완료!
      print(pref.getString('address'));
      context.go(RouterPath.homePath);
    } else {
      // 처음 로그인한 유저. 추가정보 입력으로 보내기
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString('accessToken', user.accessToken);
      // context.pushNamed('addadditionalinfo');

      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) => AddAdditionalInfo()));
    }
    // debugPrint(res);
  }
}
