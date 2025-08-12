// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:petshop/Utils/utils.dart';
import 'package:petshop/common/app_constants.dart';
import 'package:petshop/service/graphql_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class AuthService with ChangeNotifier {
  late ValueNotifier<GraphQLClient> client = GraphqlConfig.initializeClient();

  AuthService({bool? ignoreToken}) {
    _initializeClient(ignoreToken: ignoreToken);
  }

  Future<void> _initializeClient({bool? ignoreToken}) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString(AppConstants.keyToken);
    client = GraphqlConfig.initializeClient(token: ignoreToken == true ? null : token);
    notifyListeners();
  }

  // User data
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  // Token management
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
  }

  // Check Login
  bool checkLoginStatus(Map<String, dynamic>? result) {
    return result != null && result['token'] != null;
  }

  Future<Map<String, dynamic>?> fetchUserInfo() async {
    const String getUserQuery = '''
  query {
    me {
      id
      email
      firstName
      lastName
      isActive
      isStaff
      dateJoined
      lastLogin
      languageCode
      defaultShippingAddress {
        streetAddress1
        city
        postalCode
      }
      defaultBillingAddress {
        streetAddress1
        city
        postalCode
      }
      addresses {
        id
        firstName
        lastName
        streetAddress1
        city
        postalCode
      }
      avatar {
        url
      }
      checkout {
        id
        totalPrice {
          gross {
            amount
            currency
          }
        }
        lines {
          quantity
          variant {
            id
            name
            product {
              name
              thumbnail {
                url
              }
            }
          }
        }
      }
      orders(first: 100) {
        edges {
          node {
            id
            number
            created
            status
            total {
              gross {
                amount
                currency
              }
            }
            lines {
            quantity
          variant {
            id
            name
            product {
              name
              thumbnail {
                url
              }
              pricing {
                priceRange {
                  start {
                    net {
                      currency
                      amount
                    }
                  }
                }
              }
            }
          }
          }
          }
        }
      }
    }
  }
  ''';

    final QueryOptions options = QueryOptions(
      document: gql(getUserQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.value.query(options);
    notifyListeners();

    if (result.hasException) {
      // ====================================== hết hạn token ======================================
      if (result.exception?.graphqlErrors.first.extensions?['exception']?['code'] ==
          AppConstants.keyExpiredToken) {
        print('LINH_HET_TOKEN111');
        final response = await refreshToken();
        if (response == null) {
          return null;
        }
        return fetchUserInfo();
      }
      return null;
    }

    return result.data?['me'];
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    const String loginMutation = '''
    mutation TokenCreate(\$email: String!, \$password: String!) {
      tokenCreate(email: \$email, password: \$password) {
        token
        refreshToken
        csrfToken
        user {
          id
          email
          firstName
          lastName
          checkoutIds
          defaultBillingAddress {
            firstName
            lastName
            companyName
            streetAddress1
            streetAddress2
            city
            cityArea
            postalCode
            country {
              code
              country
            }
            countryArea
            phone
            isDefaultBillingAddress
            isDefaultShippingAddress
          }
        }   
        errors {
          field
          message
          code
        }   
      }
    }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(loginMutation),
      variables: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );

    final QueryResult result = await client.value.mutate(options);

    if (result.hasException) {
      print(result.exception.toString());
      return null;
    }

    return result.data?['tokenCreate'];
  }

  Future<void> logout(String pluginId) async {
    const String logoutMutation = '''
  mutation externalLogout(\$input: JSONString!, \$pluginId: String!) {
    externalLogout(input: \$input, pluginId: \$pluginId) {
      accountErrors {
        field
        message
      }
    }
  }
  ''';

    final String inputJson = '{}';

    final MutationOptions options = MutationOptions(
      document: gql(logoutMutation),
      variables: {
        'input': inputJson,
        'pluginId': pluginId,
      },
    );

    final QueryResult result = await client.value.mutate(options);

    if (result.hasException) {
      // ====================================== hết hạn token ======================================
      if (result.exception?.graphqlErrors.first.extensions?['exception']?['code'] ==
          AppConstants.keyExpiredToken) {
        print('LINH_HET_TOKEN');
        // final response = await refreshToken();
        // if (response == null) {
        //   return null;
        // }
        // return logout();
      }
    } else {
      final List<dynamic> accountErrors = result.data?['externalLogout']['accountErrors'];

      if (accountErrors.isNotEmpty) {
        List<String> messages = [];
        // Nếu có lỗi, in ra lỗi
        accountErrors.forEach((error) {
          messages.add(error?['message']);
          Utils().showToast(messages.toString(), ToastType.failed);
        });
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }
    }
  }

  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String redirectUrl,
  }) async {
    const String registerMutation = '''
  mutation accountRegister(\$email: String!, \$password: String!, \$firstName: String!, \$lastName: String!, \$redirectUrl: String!) {
    accountRegister(input: { email: \$email, password: \$password, firstName: \$firstName, lastName: \$lastName, redirectUrl: \$redirectUrl }) {
      accountErrors {
        field
        message
      }
      user {
        id
        email
        firstName
        lastName
        isActive
        isStaff
        dateJoined
        lastLogin
        languageCode
        defaultShippingAddress {
          streetAddress1
          city
          postalCode
        }
        defaultBillingAddress {
          streetAddress1
          city
          postalCode
        }
        addresses {
          streetAddress1
          city
          postalCode
        }
        avatar {
          url
        }
      }
    }
  }
  ''';

    final MutationOptions options = MutationOptions(
      document: gql(registerMutation),
      variables: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'redirectUrl': redirectUrl,
        'channelSlug': 'default'
      },
    );

    final QueryResult result = await client.value.mutate(options);

    if (result.hasException) {
      print(result.exception.toString());
      return null;
    }

    return result.data;
  }

  Future<Map<String, dynamic>?> updateAccount({
    required String firstName,
    required String lastName,
  }) async {
    const String updateAccountMutation = '''
    mutation accountUpdate(\$firstName: String!, \$lastName: String!) {
      accountUpdate(input: { firstName: \$firstName, lastName: \$lastName }) {
        user {
          id
          email
          firstName
          lastName
        }
        accountErrors {
          field
          message
          code
        }
      }
    }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(updateAccountMutation),
      variables: {
        'firstName': firstName,
        'lastName': lastName, // Truyền lastName vào biến
      },
    );

    final QueryResult result = await client.value.mutate(options);

    if (result.hasException) {
      if (result.exception?.graphqlErrors.first.extensions?['exception']?['code'] ==
          AppConstants.keyExpiredToken) {
        print('LINH_HET_TOKEN');
        final response = await refreshToken();
        if (response == null) {
          return null;
        }
        return updateAccount(firstName: firstName, lastName: lastName);
      }
      return null;
    }

    return result.data?['accountUpdate']?['user'];
  }

  Future<List<dynamic>?> fetchCategories() async {
    const String getCategoriesQuery = '''
    query {
      categories(first: 100) {
        edges {
          node {
            id
            name
            slug
          }
        }
      }
    }
  ''';

    final QueryOptions options = QueryOptions(
      document: gql(getCategoriesQuery),
    );

    final QueryResult result = await client.value.query(options);

    if (result.hasException) {
      if (result.exception?.graphqlErrors.first.extensions?['exception']?['code'] ==
          AppConstants.keyExpiredToken) {
        print('LINH_HET_TOKEN');
        final response = await refreshToken();
        if (response == null) {
          return null;
        }
        return fetchCategories();
      }
      return null;
    }

    return result.data?['categories']['edges'].map((edge) => edge['node']).toList();
  }

  Future<dynamic> createAddress({
    required String firstName,
    required String streetAddress1,
    required String city,
    required String phone,
  }) async {
    const String mutation = '''
    mutation AddAddress(\$input: AddressInput!) {
      accountAddressCreate(input: \$input) {
        address {
          id
          firstName
          lastName
          streetAddress1
          city
          postalCode
        }
        errors {
          field
          message
        }
      }
    }
  ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'input': {
          'firstName': firstName,
          'lastName': '',
          'streetAddress1': streetAddress1,
          'city': city,
          'postalCode': '90213',
          'country': 'US',
          'countryArea': 'CA',
        },
      },
    );

    final QueryResult result = await client.value.mutate(options);

    if (result.hasException) {
      if (result.exception?.graphqlErrors.first.extensions?['exception']?['code'] ==
          AppConstants.keyExpiredToken) {
        print('LINH_HET_TOKEN');
        final response = await refreshToken();
        if (response == null) {
          return null;
        }
        return createAddress(
            firstName: firstName, streetAddress1: streetAddress1, city: city, phone: phone);
      }
      return null;
    } else {
      final address = result.data?['accountAddressCreate']['address'];
      return address;
    }
  }

  Future<dynamic> setDefaultBillingAddress(
    String addressId,
  ) async {
    const String mutation = '''
    mutation SetDefaultAddress(\$addressId: ID!) {
      accountSetDefaultAddress(id: \$addressId, type: BILLING) {
        user {
          id
          email
          defaultBillingAddress {
            id
            streetAddress1
            city
            postalCode
          }
        }
        accountErrors {
          field
          message
        }
      }
    }
  ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'addressId': addressId,
      },
    );

    final QueryResult result = await client.value.mutate(options);

    if (result.hasException) {
      if (result.exception?.graphqlErrors.first.extensions?['exception']?['code'] ==
          AppConstants.keyExpiredToken) {
        print('LINH_HET_TOKEN');
        final response = await refreshToken();
        if (response == null) {
          return null;
        }
        return setDefaultBillingAddress(addressId);
      }
      return null;
    } else {
      final address = result.data?['accountSetDefaultAddress']['user']['defaultBillingAddress'];
      return address;
    }
  }

  Future<dynamic> setDefaultShippingAddress(
    String addressId,
  ) async {
    const String mutation = '''
    mutation SetDefaultAddress(\$addressId: ID!) {
      accountSetDefaultAddress(id: \$addressId, type: SHIPPING) {
        user {
          id
          email
          defaultBillingAddress {
            id
            streetAddress1
            city
            postalCode
          }
        }
        accountErrors {
          field
          message
        }
      }
    }
  ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'addressId': addressId,
      },
    );

    final QueryResult result = await client.value.mutate(options);

    if (result.hasException) {
      if (result.exception?.graphqlErrors.first.extensions?['exception']?['code'] ==
          AppConstants.keyExpiredToken) {
        print('LINH_HET_TOKEN');
        final response = await refreshToken();
        if (response == null) {
          return null;
        }
        return setDefaultShippingAddress(addressId);
      }
      return null;
    } else {
      final address = result.data?['accountSetDefaultAddress']['user']['defaultBillingAddress'];
      return address;
    }
  }

  Future<dynamic> updateCheckoutAddresses(String checkoutId, Map<String, dynamic> address) async {
    // Mutation cho cập nhật địa chỉ giao hàng
    const String updateShippingAddressMutation = '''
    mutation UpdateCheckoutShippingAddress(\$checkoutId: ID!, \$shippingAddress: AddressInput!) {
      checkoutShippingAddressUpdate(checkoutId: \$checkoutId, shippingAddress: \$shippingAddress) {
        checkout {
          id
          shippingAddress {
            firstName
            lastName
            streetAddress1
            city
            postalCode
            country {
              code
            }
          }
        }
        errors {
          field
          message
        }
      }
    }
  ''';

    // Mutation cho cập nhật địa chỉ thanh toán
    const String updateBillingAddressMutation = '''
    mutation UpdateCheckoutBillingAddress(\$checkoutId: ID!, \$billingAddress: AddressInput!) {
      checkoutBillingAddressUpdate(checkoutId: \$checkoutId, billingAddress: \$billingAddress) {
        checkout {
          id
          billingAddress {
            firstName
            lastName
            streetAddress1
            city
            postalCode
            country {
              code
            }
          }
        }
        errors {
          field
          message
        }
      }
    }
  ''';

    // Cập nhật địa chỉ giao hàng
    final MutationOptions shippingOptions = MutationOptions(
      document: gql(updateShippingAddressMutation),
      variables: {
        'checkoutId': checkoutId,
        'shippingAddress': address,
      },
    );

    final QueryResult shippingResult = await client.value.mutate(shippingOptions);

    if (shippingResult.hasException) {
      if (shippingResult.exception?.graphqlErrors.first.extensions?['exception']?['code'] ==
          AppConstants.keyExpiredToken) {
        print('LINH_HET_TOKEN');
        final response = await refreshToken();
        if (response == null) {
          return null;
        }
        return updateCheckoutAddresses(checkoutId, address);
      }
      return null;
    } else {
      // Cập nhật địa chỉ thanh toán
      final MutationOptions billingOptions = MutationOptions(
        document: gql(updateBillingAddressMutation),
        variables: {
          'checkoutId': checkoutId,
          'billingAddress': address,
        },
      );

      final QueryResult billingResult = await client.value.mutate(billingOptions);

      if (billingResult.hasException) {
        return null;
      } else {
        final billingAddress = billingResult;
        return billingAddress;
      }
    }
  }

  Future<bool> requestPasswordReset(String email, String redirectUrl) async {
    const String requestPasswordResetMutation = '''
    mutation requestPasswordReset(\$email: String!, \$redirectUrl: String!) {
      requestPasswordReset(email: \$email, redirectUrl: \$redirectUrl) {
        accountErrors {
          field
          message
          code
        }
      }
    }
  ''';

    final MutationOptions options = MutationOptions(
      document: gql(requestPasswordResetMutation),
      variables: {
        'email': email,
        'redirectUrl': redirectUrl,
      },
    );

    final QueryResult result = await client.value.mutate(options);

    if (result.hasException) {
      return false;
    }

    // Check if there are any errors
    final List<dynamic>? errors = result.data?['requestPasswordReset']['accountErrors'];
    if (errors != null && errors.isNotEmpty) {
      bool isReadySend = false;
      for (var error in errors) {
        print(error);
        if (error['code'] == 'PASSWORD_RESET_ALREADY_REQUESTED') {
          isReadySend = true;
        }
        Utils().showToast(error['message'], ToastType.failed);
      }
      return isReadySend;
    }

    return true;
  }

  Future<Map<String, dynamic>?> setPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    const String setPasswordMutation = '''
    mutation setPassword(\$token: String!, \$email: String!, \$password: String!) {
      setPassword(token: \$token, email: \$email, password: \$password) {
        accountErrors {
          field
          message
          code
        }
        user {
          id
          email
          isActive
        }
      }
    }
  ''';

    final MutationOptions options = MutationOptions(
      document: gql(setPasswordMutation),
      variables: {
        'token': token,
        'email': email,
        'password': password,
      },
    );

    final QueryResult result = await client.value.mutate(options);

    if (result.hasException) {
      Utils().showToast(result.exception.toString(), ToastType.failed);
      return null;
    }
    if (result.hasException ||
        ((result.data?['setPassword']?['accountErrors']) is List &&
            (result.data?['setPassword']?['accountErrors'] as List).isNotEmpty)) {
      for (var err in result.data?['setPassword']?['accountErrors']) {
        Utils().showToast(err?['message'], ToastType.failed);
      }
      return null;
    }

    return result.data?['setPassword'];
  }

  Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    String refreshToken = prefs.getString(AppConstants.keyRefreshToken) ?? '';

    const String refreshTokenMutation = '''
  mutation RefreshToken(\$refreshToken: String!) {
    tokenRefresh(refreshToken: \$refreshToken) {
      token
      errors {
        field
        message
      }
    }
  }
  ''';

    final MutationOptions options = MutationOptions(
      document: gql(refreshTokenMutation),
      variables: {
        'refreshToken': refreshToken,
      },
    );

    final QueryResult result = await GraphqlConfig.initializeClient().value.mutate(options);

    if (result.hasException) {
      print('Error refreshing token: ${result.exception.toString()}');
      return null;
    }

    final data = result.data?['tokenRefresh'];
    if (data != null && data['token'] != null) {
      client = GraphqlConfig.initializeClient(token: data['token']);
      await prefs.setString(AppConstants.keyToken, data['token']);
      return data['token'];
    } else {
      return null;
    }
  }
}
