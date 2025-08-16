import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:petshop/common/helper/utils.dart';
import 'package:petshop/common/app_constants.dart';
import 'package:petshop/components/button_custom_content.dart';
import 'package:petshop/components/loading.dart';
import 'package:petshop/model/product_model.dart';
import 'package:petshop/service/checkout_service.dart';
import 'package:petshop/service/loading_service.dart';
import 'package:petshop/core/themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/pet-detail';

  const ProductDetailScreen(this.product, {super.key});
  final ProductModel product;
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CheckoutService checkoutService = CheckoutService();
  final LoadingService loadingService = GetIt.I<LoadingService>();
  bool haveCheckout = false;
  handleAddToCart() async {
    int id = loadingService.showLoading();
    String currentCheckOutId = await AppConstants.getCheckoutId();
    if (currentCheckOutId.isEmpty) {
      handleCreateCheckOutId();
      loadingService.hideLoading(id);
      return;
    }
    final response = await checkoutService.addToCart(
      currentCheckOutId,
      widget.product.variants!.first.id,
      1,
    );
    loadingService.hideLoading(id);
    if (!response) {
      Utils().showToast('Thêm vào giỏ hàng thất bại', ToastType.failed);
      return;
    }
    Utils().showToast('Thêm vào giỏ hàng thành công', ToastType.success);
  }

  handleCreateCheckOutId() async {
    int id = loadingService.showLoading();

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString(AppConstants.keyToken);
    Map<String, dynamic> deCodeToken = JwtDecoder.decode(token!);
    final response = await checkoutService.createCheckout(
      deCodeToken['email'] ?? '',
      [
        {"variantId": widget.product.variants?.first.id, "quantity": 1}
      ],
      AppConstants.channelDefault,
    );
    loadingService.hideLoading(id);
    if (response?['checkout']?['id'] == null) {
      Utils().showToast('Thêm vào giỏ hàng thất bại', ToastType.failed);
      return;
    }
    await AppConstants.setCheckoutId(response?['checkout']?['id']);
    Utils().showToast('Thêm vào giỏ hàng thành công', ToastType.success);

    // handleAddToCart();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () {});
  }

  handleGetCheckouts() async {}

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pet Shop',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primary_700,
          leading: ButtonCustomContent(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top + 1000,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Container(
                      //       height: 300,
                      //       width: MediaQuery.of(context).size.width - 32,
                      //       decoration: const BoxDecoration(
                      //         shape: BoxShape.circle,
                      //       ),
                      //       child: Image.network(
                      //         product.thumbnailUrl,
                      //         fit: BoxFit.contain,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      ImageSlideshow(
                        height: 300,
                        isLoop: false,
                        children: [
                          ...(widget.product.media ?? []).map((media) {
                            return SizedBox(
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                media.url,
                                fit: BoxFit.contain,
                              ),
                            );
                          })
                        ],
                      ),
                      const SizedBox(height: 20),
                      //Product name
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      //Product price
                      Text(
                        formatCurrency(widget.product.pricing.priceRange.start.amount),
                        style: TextStyle(
                          color: Utils().hexToColor('#e65400'),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      //Product description

                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        getDescription(),
                        textAlign: TextAlign.justify,
                        softWrap: true,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: AppColors.primary_200,
                  child: Row(
                    children: [
                      ButtonCustomContent(
                        onTap: () {
                          handleAddToCart();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 1,
                          height: 55,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_shopping_cart_rounded,
                                color: AppColors.primary_700,
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Text(
                                'Thêm vào giỏ hàng',
                                style: TextStyle(color: AppColors.primary_700),
                              )
                            ],
                          ),
                        ),
                      ),
                      // Container(
                      //   height: 50,
                      //   width: 1,
                      //   color: AppColors.primary_700,
                      // ),
                      // ButtonCustomContent(
                      //   color: Utils().hexToColor('#e65400'),
                      //   radius: BorderRadius.circular(0),
                      //   onTap: () {},
                      //   child: Container(
                      //     height: 55,
                      //     alignment: Alignment.center,
                      //     width: MediaQuery.of(context).size.width * 0.6 - 1,
                      //     padding: const EdgeInsets.symmetric(vertical: 4),
                      //     child: const Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Text(
                      //           'Mua ngay',
                      //           style: TextStyle(
                      //               color: Colors.white,
                      //               fontSize: 18,
                      //               fontWeight: FontWeight.bold),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
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

  String getDescription() {
    dynamic des = jsonDecode(widget.product.description)?['blocks'];
    if (des is List && (des).isNotEmpty) {
      return (des).first?['data']?['text'] ?? '--';
    }
    return '--';
  }
}
