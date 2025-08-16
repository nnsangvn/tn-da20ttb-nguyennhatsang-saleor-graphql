import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:petshop/common/helper/utils.dart';
import 'package:petshop/common/app_constants.dart';
import 'package:petshop/components/button_custom_content.dart';
import 'package:petshop/components/input_base.dart';
import 'package:petshop/model/product_model.dart';
import 'package:petshop/screen/product/product_detail_screen.dart';
import 'package:petshop/service/auth_service.dart';
import 'package:petshop/service/loading_service.dart';
import 'package:petshop/service/product_service.dart';
import 'package:petshop/core/themes/colors.dart';

enum TabType { dog, cat, rabbit }

class ProductOverviewScreen extends StatelessWidget {
  static const routeName = '/overview';

  final Map<String, dynamic>? userData;
  const ProductOverviewScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return const TabBarExample(); // Sử dụng TabBarExample làm trang chính
  }
}

class TabBarExample extends StatefulWidget {
  const TabBarExample({super.key});

  @override
  State<TabBarExample> createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<TabBarExample> {
  final AuthService _authService = AuthService();
  List<dynamic> dogCategories = [];
  List<dynamic> catCategories = [];
  List<dynamic> rabbitCategories = [];
  final LoadingService loadingService = GetIt.I<LoadingService>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      handleGetCategories();
    });
  }

  handleGetCategories() async {
    int a = loadingService.showLoading();
    final response = await _authService.fetchCategories();
    loadingService.hideLoading(a);

    if (response == null) {
      Utils().showToast('Đã có lỗi xảy ra trong quá trình xử lý', ToastType.failed);
      return;
    }
    for (var category in response) {
      String? slug = category?['slug'];
      if (category?['id'] == null || slug == null) {
        continue;
      }
      if (slug == AppConstants.keyDogFood ||
          slug == AppConstants.keyDogClothes ||
          slug == AppConstants.keyDogItem) {
        dogCategories = dogCategories..add(category);
        continue;
      }
      if (slug == AppConstants.keyCatFood ||
          slug == AppConstants.keyCatClothes ||
          slug == AppConstants.keyCatItem) {
        catCategories = catCategories..add(category);
        continue;
      }
      rabbitCategories = rabbitCategories..add(category);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Pet Shop',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.primary_700,
            bottom: TabBar(
              dividerColor: Colors.transparent,
              unselectedLabelColor: AppColors.primary_300,
              labelColor: Colors.white,
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              tabs: const <Widget>[
                Tab(text: 'Chó'),
                Tab(text: 'Mèo'),
                Tab(text: 'Thỏ'),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              NestedTabBar(
                type: TabType.dog,
                categories: dogCategories,
              ),
              NestedTabBar(
                type: TabType.cat,
                categories: catCategories,
              ),
              NestedTabBar(
                type: TabType.rabbit,
                categories: rabbitCategories,
              ),
            ],
          )),
    );
  }
}

class NestedTabBar extends StatefulWidget {
  const NestedTabBar({
    super.key,
    required this.type,
    required this.categories,
  });
  final TabType type;
  final List<dynamic> categories;
  @override
  State<NestedTabBar> createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar> with TickerProviderStateMixin {
  List<DropdownMenuItem> items = [];
  List<dynamic> categories = [];
  final LoadingService loadingService = GetIt.I<LoadingService>();
  dynamic categorySelected;
  final AuthService authService = AuthService();
  final ProductService productService = ProductService();
  List<ProductModel>? products;
  @override
  void initState() {
    super.initState();
    setState(() {
      categories = widget.categories;
      categorySelected = widget.categories.isNotEmpty ? categories.first : null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (categorySelected != null) {
        handleGetProduct();
      }
    });
  }

  handleGetProduct() async {
    int idLoading = loadingService.showLoading();
    if (categorySelected?['id'] == null) {
      return;
    }
    final response = await productService
        .fetchProductsForUser(categorySelected?['id'], AppConstants.channelDefault, filter: {
      'search': valueSearch,
    });
    loadingService.hideLoading(idLoading);

    setState(() {
      products = response ?? [];
    });
  }

  @override
  void didUpdateWidget(covariant NestedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      categories = widget.categories;
      categorySelected = widget.categories.isNotEmpty ? categories.first : null;
    });
    Future.delayed(const Duration(microseconds: 250), () {
      if (categorySelected != null) {
        handleGetProduct();
      }
    });
  }

  handleShowModalFilter() {
    showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 20, bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...categories.map(
              (e) {
                return ButtonCustomContent(
                  onTap: () {
                    setState(() {
                      categorySelected = e;
                    });
                    handleGetProduct();
                    Navigator.of(context).pop();
                  },
                  color: e?['id'] == categorySelected?['id'] ? AppColors.primary_200 : Colors.white,
                  radius: const BorderRadius.all(Radius.circular(0)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Text(
                          e?['name'] ?? '--',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: e['id'] == categorySelected?['id']
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  String valueSearch = '';
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: InputBase(
                    hintText: "Nhập tên sản phẩm",
                    obscureText: false,
                    onChanged: (text) {
                      timer?.cancel();
                      setState(() {
                        valueSearch = text;
                      });
                      timer = Timer(const Duration(milliseconds: 1000), () {
                        handleGetProduct();
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                ButtonCustomContent(
                  onTap: () {
                    handleShowModalFilter();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: AppColors.primary_700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          color: AppColors.primary_700,
                        ),
                        // const SizedBox(
                        //   width: 8,
                        // ),
                        // Text(
                        //   categorySelected?['name'] ?? '',
                        //   style: TextStyle(
                        //       fontSize: 16, color: AppColors.primary_700),
                        // )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (products?.isEmpty == true) ...[
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: const Text('Không có sản phẩm!'),
              ),
            )
          ],
          if (products != null) ...[
            Expanded(
              child: GridView.builder(
                itemCount: products?.length ?? 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Số cột
                  childAspectRatio: 0.7, // Tỷ lệ chiều cao/chiều rộng của mỗi ô
                  crossAxisSpacing: 10, // Khoảng cách giữa các ô theo chiều ngang
                  mainAxisSpacing: 10, // Khoảng cách giữa các ô theo chiều dọc
                ),
                itemBuilder: (context, index) {
                  return _buildProductItem(product: products![index]);
                },
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildProductItem({required ProductModel product}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: ButtonCustomContent(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product),
            ),
          );
        },
        radius: BorderRadius.circular(8),
        color: AppColors.primary_200,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 1,
            vertical: 1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Image.network(
                    product.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      formatCurrency(product.pricing.priceRange.start.amount),
                      maxLines: 1,
                      style: TextStyle(
                          color: Utils().hexToColor('#e65400'),
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String formatCurrency(double amount) {
    final format = NumberFormat.currency(
        locale: 'vi_VN', decimalDigits: 0, symbol: AppConstants.subValuePrice);
    return format.format(amount);
  }
}
