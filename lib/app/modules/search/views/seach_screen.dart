import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final RxInt selectedTab = 0.obs;
  final RxString searchText = "".obs;
  final userController = Get.find<UserController>();

  final RxList<UserModel> allAccounts = <UserModel>[].obs;

  final tabs = ['All', 'Top Accounts', 'Recent', 'Tags'];

  late TabController _tabController;
  String defaultImage =
      "https://imgs.search.brave.com/FVkm8Pb-D2NPJAObzktowhIeYsE2dzU3U9RHHFeivBE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzA5LzExLzA0Lzcz/LzM2MF9GXzkxMTA0/NzMzNF9MM2s4SUdj/bG9rNDV0QkdRMEVo/bVNDWXBCcTBPd2lw/bC5qcGc";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  final RxList<UserModel> searchResults = <UserModel>[].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 5),
            CustomTextField(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(width: 1, color: Colors.grey),
              ),
              hintText: "Search",
              prefixIcon: Icons.search,
              onChanged: (value) {
                searchText.value = value;
                if (value.isNotEmpty) {
                  userController.searchUser(search: value).then((value) {
                    if (value != null) {
                      searchResults.value = value;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 15),
            _buildAppTabBar(),
            const SizedBox(height: 15),

            // Expanded(
            //   child: Obx(
            //     () => AnimatedCrossFade(
            //       firstChild: buildAllandTopAccounts(),
            //       secondChild: Container(color: Colors.green),
            //       crossFadeState:
            //           searchText.isEmpty
            //               ? CrossFadeState.showFirst
            //               : CrossFadeState.showSecond,
            //       duration: const Duration(milliseconds: 300),
            //     ),
            //   ),
            // ),
            Obx(() {
              if (searchText.isEmpty) {
                return buildAllandTopAccounts();
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(
                      "search",
                      index,
                      searchResults[index],
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildAllandTopAccounts() {
    return Expanded(
      key: const Key("allandtopaccounts"),
      child: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          FutureBuilder(
            future: userController.getAllAccounts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: Get.height * 0.5,
                  width: Get.width,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(
                  height: Get.height * 0.5,
                  width: Get.width,
                  child: const Center(child: Text("No accounts found")),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return _buildUserCard("all", index, snapshot.data![index]);
                },
              );
            },
          ),
          FutureBuilder(
            future: userController.getTopAccounts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: Get.height * 0.5,
                  width: Get.width,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(
                  height: Get.height * 0.5,
                  width: Get.width,
                  child: const Center(child: Text("No accounts found")),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return _buildUserCard("all", index, snapshot.data![index]);
                },
              );
            },
          ),

          // ListView.builder(
          //   itemCount: 4,
          //   itemBuilder: (context, index) {
          //     return _buildUserCard(
          //       "top accounts",
          //       index,
          //       allAccounts[index],
          //     );
          //   },
          // ),
          // ListView.builder(
          //   itemCount: 4,
          //   itemBuilder: (context, index) {
          //     return _buildUserCard(
          //       "recent",
          //       index,
          //       allAccounts[index],
          //     );
          //   },
          // ),
          // ListView.builder(
          //   itemCount: 4,
          //   itemBuilder: (context, index) {
          //     return _buildUserCard("tags", index, allAccounts[index]);
          //   },
          // ),
        ],
      ),
    );
  }

  Container _buildAppTabBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        tabs: [
          Tab(text: 'All'),
          Tab(text: 'Top Accounts'),
          // Tab(text: 'Recent'),
          // Tab(text: 'Tags'),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFE7E6),
      centerTitle: true,
      title: Text(
        "Search People",
        style: Get.textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: InkWell(
          onTap: () => Get.back(),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
      leadingWidth: 35,
    );
  }

  Widget _buildUserCard(String type, int index, UserModel user) {
    return Container(
      width: Get.width,
      height: 100,
      padding: const EdgeInsets.all(7),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 0),
            color: const Color.fromARGB(12, 0, 0, 0),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.profile, arguments: {"userId": user.id});
        },
        child: Row(
          children: [
            Container(
              width: 75,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(
                    user.avatarUrl!.isEmpty ? defaultImage : user.avatarUrl!,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName ?? "", style: Get.textTheme.bodyMedium),
                Obx(
                  () => Text(
                    "${user.followerCount?.value} followers",
                    style: Get.textTheme.bodySmall,
                  ),
                ),
                const Spacer(),
                if (type == "tags")
                  Text(
                    "#love #school",
                    style: GoogleFonts.montserrat(
                      color: Colors.grey,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Obx(() {
                  final isFollowing = user.isFollowing?.value ?? false;
                  return SizedBox(
                    width: 95,
                    child: CustomButton(
                      ontap: () async {
                        user.isFollowing?.value = !isFollowing;
                        if (isFollowing &&
                            user.followerCount?.value != null &&
                            user.followerCount?.value != 0) {
                          user.followerCount?.value -= 1;
                        } else {
                          user.followerCount?.value += 1;
                        }
                        await userController.toggleFollow(followId: user.id!);
                      },
                      isLoading: false.obs,
                      bgColor:
                          isFollowing ? Colors.grey : AppColors.primaryColor,
                      height: 32,
                      child: Text(
                        isFollowing ? "Following" : "Follow",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const Spacer(),
            if (type == "top accounts")
              Text(
                "#${index + 1} trending",
                style: GoogleFonts.montserrat(
                  color: Color.fromRGBO(251, 201, 5, 1),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const Spacer(),
            IconButton(onPressed: () {}, icon: Icon(Icons.arrow_forward_ios)),
          ],
        ),
      ),
    );
  }
}
