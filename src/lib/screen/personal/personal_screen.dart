import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:petshop/common/helper/utils.dart';
import 'package:petshop/components/button_base.dart';
import 'package:petshop/components/button_custom_content.dart';
import 'package:petshop/components/input_base.dart';
import 'package:petshop/model/user_model.dart';
import 'package:petshop/service/auth_service.dart';
import 'package:petshop/service/loading_service.dart';
import 'package:petshop/service/login_or_register.dart';
import 'package:petshop/core/themes/colors.dart';

class ProfileEdit extends StatefulWidget {
  static const routeName = '/personal';
  final void Function()? onTap;
  const ProfileEdit({super.key, this.onTap});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final AuthService _authService = AuthService();
  final LoadingService loadingService = GetIt.I<LoadingService>();
  bool isShowFormChangeInformation = false;
  UserInfo? userInfo;
  final TextEditingController textEditingControllerUser = TextEditingController();
  final TextEditingController textEditingControllerPhoneNumber = TextEditingController();
  String? userName;
  String? email;
  String? phoneNumber;
  String? street;
  String? city;

  // Logout function
  void _logout() async {
    int id = loadingService.showLoading();
    await _authService.logout('Global');
    loadingService.hideLoading(id);
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginOrRegister(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    handleGetUserInfo();
  }

  handleGetUserInfo() {
    Future.delayed(const Duration(milliseconds: 500), () async {
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
      setState(() {
        userName = response['firstName'];
        email = response['email'];
        phoneNumber = response['lastName'];
      });
      textEditingControllerUser.text = response['firstName'] ?? '';
      textEditingControllerPhoneNumber.text = response['lastName'] ?? '';
    });
  }

  static bool validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return false;
    }

    // Thay thế +84 bằng 0
    String newPhone = phone.replaceFirst('+84', '0');

    // Kiểm tra xem số có bắt đầu bằng 84 không và thay thế bằng 0
    String code = newPhone.substring(0, 2);
    if (code == '84') {
      newPhone = '0' + newPhone.substring(2);
    }

    // Kiểm tra xem chuỗi chỉ chứa số
    if (!RegExp(r'^[0-9\b]+$').hasMatch(newPhone)) {
      return false;
    }

    // Kiểm tra định dạng hợp lệ của số điện thoại
    bool valid = RegExp(r'^(03|05|07|08|09|01[2|6|8|9]|02[0-9])+([0-9]{8})\b').hasMatch(newPhone);
    bool valid1 = RegExp(r'^(19|18)+([0-9]{6,9})\b').hasMatch(newPhone);

    return valid || valid1;
  }

  handleChangeInfo() async {
    if (!validatePhone(textEditingControllerPhoneNumber.text)) {
      Utils().showToast('Số điện thoại không hợp lệ', ToastType.failed);
      return;
    }
    int id = loadingService.showLoading();
    final response = await _authService.updateAccount(
      firstName: textEditingControllerUser.text,
      lastName: textEditingControllerPhoneNumber.text,
    );
    loadingService.hideLoading(id);
    if (response == null) {
      Utils().showToast('Đã có lỗi xảy ra trong quá trình xử lý', ToastType.failed);
      return;
    }
    setState(() {
      isShowFormChangeInformation = false;
      userName = response['firstName'];
      email = response['email'];
      phoneNumber = response['lastName'];
    });
    textEditingControllerUser.text = response['firstName'] ?? '';
    textEditingControllerPhoneNumber.text = response['lastName'] ?? '';
  }

  @override
  void dispose() {
    super.dispose();
  }

  handleCreateAddress() async {
    int id = loadingService.showLoading();
    final response = await _authService.createAddress(
      firstName: userName ?? '',
      streetAddress1: street ?? '',
      city: city ?? '',
      phone: phoneNumber ?? '',
    );
    if (response?['id'] == null) {
      loadingService.hideLoading(id);
      Utils().showToast('Thêm địa chỉ thất bại', ToastType.failed);
      return;
    }
    final responseUpdateDefaultBilling =
        await _authService.setDefaultBillingAddress(response?['id']);
    final responseUpdateDefaultShipping =
        await _authService.setDefaultShippingAddress(response?['id']);
    loadingService.hideLoading(id);
    if (responseUpdateDefaultBilling == null || responseUpdateDefaultShipping == null) {
      Utils().showToast('Thêm địa chỉ thất bại', ToastType.failed);
      return;
    }
    Utils().showToast('Thêm địa chỉ thành công', ToastType.success);
    handleGetUserInfo();
  }

  handleShowModalAddAddress({bool? isUpdate}) {
    showBarModalBottomSheet(
      expand: false,
      context: context,
      topControl: const SizedBox(),
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 0, bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: AppColors.primary_700,
              child: Text(
                isUpdate == true ? 'Sửa địa chỉ' : 'Thêm địa chỉ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InputBase(
                    hintText: 'Địa chỉ (vd: số nhà, đường, xã quận huyện)',
                    obscureText: false,
                    onChanged: (text) {
                      setState(() {
                        street = text;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  InputBase(
                    hintText: 'Thành phố',
                    obscureText: false,
                    onChanged: (text) {
                      setState(() {
                        city = text;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ButtonBase(
                    text: 'Lưu địa chỉ',
                    onTap: () {
                      if (street == null || city == null) {
                        Utils().showToast('Vui lòng nhập đầy đủ thông tin', ToastType.failed);
                        return;
                      }
                      Navigator.of(context).pop();
                      handleCreateAddress();
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Trang cá nhân",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primary_700,
              automaticallyImplyLeading: false,
              actions: [
                ButtonCustomContent(
                  onTap: () {
                    if (isShowFormChangeInformation) {
                      setState(() {
                        isShowFormChangeInformation = false;
                      });
                      return;
                    }
                    textEditingControllerUser.text = userName ?? '';
                    textEditingControllerPhoneNumber.text = phoneNumber ?? '';
                    setState(() {
                      isShowFormChangeInformation = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
                    child: Icon(
                      isShowFormChangeInformation ? Icons.cancel_rounded : Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            body: (userName != null || email != null)
                ? Container(
                    padding: const EdgeInsets.all(16),
                    child: !isShowFormChangeInformation
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset('assets/pet_shop_logo.jpg'),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          width: 1,
                                          color: AppColors.primary_300,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Tên',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          userName ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          width: 1,
                                          color: AppColors.primary_300,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Email',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          email ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          width: 1,
                                          color: AppColors.primary_300,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Số điện thoại',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          phoneNumber ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          width: 1,
                                          color: AppColors.primary_300,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Địa chỉ',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Row(
                                          children: [
                                            // có địa chỉ
                                            if (userInfo?.defaultBillingAddress != null) ...[
                                              Text(
                                                '${userInfo?.defaultBillingAddress?.streetAddress1 ?? '--'}, ${userInfo?.defaultBillingAddress?.city ?? '--'}',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ],
                                            // không có địa chỉ
                                            if (userInfo?.defaultBillingAddress == null) ...[
                                              ButtonBase(
                                                text: 'Thêm',
                                                onTap: () {
                                                  handleShowModalAddAddress();
                                                },
                                              )
                                            ],
                                            if (userInfo?.defaultBillingAddress != null) ...[
                                              const SizedBox(
                                                width: 16,
                                              ),
                                              ButtonBase(
                                                text: 'Sửa',
                                                onTap: () {
                                                  handleShowModalAddAddress(isUpdate: true);
                                                },
                                              )
                                            ]
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              ButtonBase(
                                text: "Đăng xuất",
                                onTap: _logout,
                                customBackgroundColor: Colors.red,
                              )
                            ],
                          )
                        : Column(
                            children: [
                              Image.asset('assets/pet_shop_logo.jpg'),
                              const SizedBox(
                                height: 32,
                              ),
                              InputBase(
                                controller: textEditingControllerUser,
                                hintText: "Nhập tên",
                                obscureText: false,
                                onChanged: (text) {
                                  textEditingControllerUser.text = text;
                                },
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              InputBase(
                                controller: textEditingControllerPhoneNumber,
                                hintText: "Nhập số điện thoại",
                                obscureText: false,
                                onChanged: (text) {
                                  textEditingControllerPhoneNumber.text = text;
                                },
                              ),
                              const SizedBox(
                                height: 32,
                              ),
                              ButtonBase(
                                text: "Lưu",
                                onTap: email != null &&
                                        email!.isNotEmpty &&
                                        userName != null &&
                                        userName!.isNotEmpty
                                    ? handleChangeInfo
                                    : null,
                              ),
                            ],
                          ),
                  )
                : Container(),
          );
        },
      ),
    );
  }
}
