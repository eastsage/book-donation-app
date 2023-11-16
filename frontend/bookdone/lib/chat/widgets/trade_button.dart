import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../rest_api/rest_client.dart';

class TradeButton extends HookConsumerWidget {
  final tradeId;

  const TradeButton({super.key, required this.tradeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);
    final userId = useState<int>(-1);

    final receiveUserId = useState<int>(-1);
    final donationId = useState<int>(-1);
    final tradeStatus = useState<String?>(null);

    final isLeftButtonPressed = useState<bool>(false);
    final isRightButtonPressed = useState<bool>(false);

    // 유저 정보 읽기
    Future<void> readUserInfo() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      userId.value = pref.getInt('userId') ?? 0;
    }

    // 거래 정보 가져오기
    fetchTradeInfo() async {
      try {
        await readUserInfo();
        final tradeResponse = await restClient.getDonationIdByTradeId(tradeId);
        receiveUserId.value = tradeResponse.data.memberId;
        tradeStatus.value = tradeResponse.data.tradeStatus;
        donationId.value = tradeResponse.data.donationId;

        print('tradeId: $tradeId');
        print('receiveUserId: ${receiveUserId.value}');
        print('tradeStatus: ${tradeStatus.value}');
      } catch (e) {
        print('Error fetching trade widget call info: $e');
      }
    }

    useEffect(() {
      fetchTradeInfo();
    }, []);

    Future<void> updateTradeStatus() async {
      try {
        switch (tradeStatus.value) {
          case "NONE":
            await restClient.reservationRequestTrade(
                donationId.value, receiveUserId.value);
            break;
          case "DONATION_REQUESTED":
            await restClient.reservationConfirmTrade(
                donationId.value, receiveUserId.value);
            break;
          case "DONATION_CONFIRMED":
            await restClient.completionRequestTrade(
                donationId.value, receiveUserId.value);
            break;
          case "COMPLETION_REQUESTED":
            await restClient.completionConfirmTrade(
                donationId.value, receiveUserId.value);
            break;
          default:
            print("Invalid trade status");
        }
        fetchTradeInfo(); // Refresh trade info after updating
      } catch (e) {
        print('Error in updating trade status: $e');
      }
    }

    bool isButtonEnabled() {
      if (userId.value == receiveUserId.value) {
        return tradeStatus.value == "NONE" || tradeStatus.value == "DONATION_CONFIRMED";
      } else {
        return tradeStatus.value == "DONATION_REQUESTED" || tradeStatus.value == "COMPLETION_REQUESTED";
      }
    }

    String buttonText() {
      // 현재 상태에 따라 버튼 텍스트 결정
      switch (tradeStatus.value) {
        case "NONE":
        case "DONATION_REQUESTED":
          return "기부 예약";
        case "DONATION_CONFIRMED":
        case "COMPLETION_REQUESTED":
          return "완료 확인";
        case "COMPLETION_CONFIRMED":
          return "거래 완료";
        default:
          return "액션";
      }
    }

    // 버튼 액션
    buttonAction() {
      // 현재 상태에 따라 적절한 네트워크 요청 수행
      if (isButtonEnabled()) {
        updateTradeStatus();
      }
    }

    // 취소 버튼 액션 정의
    cancelTradeAction() async {
      // 거래 취소 로직 구현
      print("거래 취소 요청");
      // TODO: 서버에 거래 취소 요청 보내는 로직 추가
    }

    // 취소 버튼 활성화 조건
    bool isCancelButtonEnabled() {
      // 취소 버튼이 활성화되는 조건을 여기에 정의
      return tradeStatus.value !=
          "COMPLETION_CONFIRMED"; // 예시: 완료 확인된 상태가 아닐 때 활성화
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: isButtonEnabled() ? buttonAction : null,
              child: Text(buttonText()),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: isCancelButtonEnabled() ? cancelTradeAction : null,
              child: Text("거래 취소"),
            ),
          ),
        ],
      ),
    );
  }
}
