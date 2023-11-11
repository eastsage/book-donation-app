import 'dart:convert';

import 'package:bookdone/bookinfo/model/donation.dart';
import 'package:bookdone/bookinfo/model/region.dart';
import 'package:bookdone/bookinfo/widgets/donating_list.dart';
import 'package:bookdone/bookinfo/widgets/keeping_list.dart';
import 'package:bookdone/bookinfo/widgets/region_dialog.dart';
import 'package:bookdone/onboard/repository/user_repository.dart';
import 'package:bookdone/rest_api/rest_client.dart';
import 'package:bookdone/router/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegionNotifier extends StateNotifier<String> {
  RegionNotifier(this.ref) : super('유저정보주소');
  final Ref ref;

  Future<void> setRegion(String region) async {
    state = region;
  }
}

final regionStateProvider =
    StateNotifierProvider<RegionNotifier, String>((ref) => RegionNotifier(ref));

class RegionIndexNotifier extends StateNotifier<int> {
  RegionIndexNotifier(this.ref) : super(0);
  final Ref ref;
  Future<void> setRegion(int index) async {
    state = index;
  }
}

final regionIndexStateProvider =
    StateNotifierProvider<RegionIndexNotifier, int>(
        (ref) => RegionIndexNotifier(ref));

class RegionNameNotifier extends StateNotifier<String> {
  RegionNameNotifier(this.ref) : super('유저정보주소');
  final Ref ref;
  Future<void> setRegion(String region) async {
    state = region;
  }
}

final regionNameStateProvider =
    StateNotifierProvider<RegionNameNotifier, String>(
        (ref) => RegionNameNotifier(ref));

class BookinfoDetail extends HookConsumerWidget {
  BookinfoDetail({super.key, required this.isbn});
  final String isbn;
  final List<Tab> tabs = <Tab>[
    Tab(
      text: '기부 중',
    ),
    Tab(
      text: "보유 중",
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restClient = ref.read(restApiClientProvider);
    final _tabController =
        useTabController(initialLength: tabs.length, initialIndex: 0);

    // 전체 지역 json 목록
    var regionList = useState<List<RegionInfo>>([]);
    // 선택 지역 index
    var selectedRegionIndex = useState(0);
    // 선택 지역 코드
    var selectedRegionCode = useState('');

    // 현재 지역 이름
    var regionName = useState('');
    // 현재 지역 코드
    var regionCode = useState('');

    Future<List<RegionInfo>> readJson() async {
      final jsonString =
          await rootBundle.loadString("assets/json/localcode.json");
      final response = await json.decode(jsonString) as Map<String, dynamic>;
      final result = Region.fromJson(response);
      print('데이터 확인 : ${result.region[0].first}');
      return result.region;
    }

    Future<String> getAddressName() async {
      var addressName = '';
      bool stop = false;
      for (int i = 0; i < regionList.value.length; i++) {
        if (!stop) {
          for (int j = 0; j < regionList.value[i].secondList.length; j++) {
            if (regionList.value[i].secondList[j].code ==
                ref.read(regionStateProvider)) {
              addressName = regionList.value[i].first;
              ref
                  .read(regionStateProvider.notifier)
                  .setRegion(regionList.value[i].secondList[0].code);
              stop = true;
              break;
            }
          }
        }
      }
      return addressName;
    }

    // Future<String> getAddress() async {
    //   var code = await ref.read(userDataRepositoryProvider).restoreAddress();
    //   return code;
    // }

    useEffect(() {
      void fetchData() async {
        try {
          final json = await readJson();
          regionList.value = json;

          final addressName = await getAddressName();
          ref.read(regionNameStateProvider.notifier).setRegion(addressName);
        } catch (error) {
          print(error);
        }
      }

      fetchData();
      return null;
    }, []);

    Future<void> selectAddress(context) async {
      showDialog(
        context: context,
        builder: (context) {
          return RegionDialog(regionList: regionList.value);
        },
      );
    }

    // readJson();
    return StatefulBuilder(builder: (context, setState) {
      return Scaffold(
          appBar: AppBar(
            // backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 12),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // readJson();

                          selectAddress(context);
                          // ref
                          //     .read(regionStateProvider.notifier)
                          //     .setRegion('주소변경값');
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            textStyle: const TextStyle(
                                fontSize: 13, fontFamily: "SCDream4"),
                            backgroundColor: Colors.brown.shade100,
                            foregroundColor: Colors.black87),
                        child: Wrap(
                          children: [
                            Icon(Icons.location_on, size: 17),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(ref.watch(regionNameStateProvider)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FutureBuilder(
                        future: restClient.getDetailBook(isbn),
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.data == null) {
                            // return SizedBox.shrink();
                            return SizedBox(
                              height: 10,
                            );
                          }
                          final book = snapshot.data!.data;

                          return Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0, bottom: 15.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: CachedNetworkImage(
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                      imageUrl: book.titleUrl,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, bottom: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            book.title,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            book.author,
                                            style: TextStyle(
                                                color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              TabBar(
                tabs: tabs,
                controller: _tabController,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.brown,
                indicatorSize: TabBarIndicatorSize.tab,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                // indicatorWeight: 2,
                // indicatorPadding:
                //     EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                labelColor: Colors.black,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 12),
                      child: DonatingList(
                        isbn: isbn,
                        // code: regionCode.value,
                        code: ref.watch(regionStateProvider),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 12),
                      child: KeepingList(
                          isbn: isbn,
                          // code: regionCode.value,
                          code: ref.watch(regionStateProvider),
                          // regionIndex: selectedRegionIndex.value,
                          regionIndex: ref.read(regionIndexStateProvider),
                          regionList: regionList.value),
                    ),
                  ],
                ),
              )
            ],
          ));
    });
  }
}
