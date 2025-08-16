import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:petshop/common/helper/utils.dart';
import 'package:petshop/common/app_constants.dart';
import 'package:petshop/components/button_custom_content.dart';
import 'package:petshop/model/checkout_response_modal.dart';
import 'package:petshop/model/user_model.dart';
import 'package:petshop/service/auth_service.dart';
import 'package:petshop/service/loading_service.dart';
import 'package:petshop/service/order_service.dart';
import 'package:petshop/core/themes/colors.dart';
import 'package:provider/provider.dart';

import '../../service/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  static const routeName = '/cart';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final AuthService _authService = AuthService();
  final CartService cartService = CartService();
  final OrderService orderService = OrderService();
  final LoadingService loadingService = GetIt.I<LoadingService>();
  CheckoutResponse? checkoutResponse;
  UserInfo? userInfo;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      handleGetUserInfo();
    });
  }

  handleGetUserInfo() async {
    int id = loadingService.showLoading();

    final response = await _authService.fetchUserInfo();

    loadingService.hideLoading(id);
    if (response == null) {
      Utils().showToast('Đã có lỗi xảy ra trong quá trình xử lý', ToastType.failed);
      return;
    }
    setState(() {
      userInfo = UserInfo.fromMap(response);
    });
    handleGetItem();
  }

  handleGetItem() async {
    String checkOutId = userInfo?.checkout?.id ?? '';
    if (checkOutId.isEmpty) {
      return;
    }
    int id = loadingService.showLoading();
    final response = await cartService.fetchDataCart(checkOutId);
    setState(() {
      checkoutResponse = response;
    });
    loadingService.hideLoading(id);
  }

  handleOrder() async {
    if (userInfo?.defaultBillingAddress == null) {
      Utils().showToast('Vui lòng thêm địa chỉ tại trang cá nhân để đặt hàng', ToastType.failed);
      return;
    }
    int id = loadingService.showLoading();
    String checkOutId = userInfo?.checkout?.id ?? '';
    final responseUpdateAddress = await _authService.updateCheckoutAddresses(checkOutId, {
      'firstName': userInfo?.firstName,
      'lastName': '',
      'streetAddress1': userInfo?.defaultBillingAddress?.streetAddress1,
      'city': userInfo?.defaultBillingAddress?.city,
      'postalCode': userInfo?.defaultBillingAddress?.postalCode,
      'country': 'US',
      'countryArea': 'CA',
    });
    if (responseUpdateAddress == null) {
      Utils().showToast('Đã có lỗi xảy ra trong quá trình xử lý', ToastType.failed);
      return;
    }
    final response = await orderService.orderCheckoutById(checkOutId);
    loadingService.hideLoading(id);
    if (response == null) {
      Utils().showToast('Đã có lỗi xảy ra trong quá trình xử lý', ToastType.failed);
      return;
    }
    AppConstants.clearCheckoutId();
    Utils().showToast('Đặt hàng thành công', ToastType.success);
    setState(() {
      checkoutResponse = null;
    });
    // handleGetUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Giỏ hàng",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary_700,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          buildCartSummary(cart, context),
          const SizedBox(
            height: 10,
          ),
          if ((checkoutResponse?.lines ?? []).isNotEmpty) ...[
            Container(
              child: Expanded(
                child: buildCartDetail(checkoutResponse?.lines ?? []),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget buildCartDetail(List<CheckoutLineCheckoutResponse> cart) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: (ButtonCustomContent(
            radius: BorderRadius.circular(8),
            color: AppColors.primary_400,
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Image.network(cart[index].variant.product.thumbnailUrl),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maxLines: 2,
                        cart[index].variant.product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'x${cart[index].quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Thành tiền: ${formatCurrency(cart[index].variant.product.pricing.start.amount * cart[index].quantity)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            ),
          )),
        );
      },
      itemCount: cart.length,
    );
  }

  double handleGetTotal() {
    double total = 0;
    for (CheckoutLineCheckoutResponse line in (checkoutResponse?.lines ?? [])) {
      total = total + (line.variant.product.pricing.start.amount * line.quantity);
    }
    return total;
  }

  Widget buildCartSummary(CartService cart, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(15),
      color: AppColors.primary_700,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'Tổng',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const Spacer(),
            Chip(
              label: Text(
                formatCurrency(handleGetTotal()),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.primary_400,
            ),
            const SizedBox(
              width: 16,
            ),
            ButtonCustomContent(
              onTap: (checkoutResponse?.lines ?? []).isEmpty
                  ? null
                  : () {
                      handleOrder();
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  'Đặt ngay',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
