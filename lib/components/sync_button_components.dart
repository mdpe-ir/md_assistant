import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:md_assistant/providers/secure_storage_provider.dart';
import 'package:md_assistant/service/app_sync.dart';
import 'package:md_assistant/utils/constant.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';

class SyncButtonComponents extends StatefulWidget {
  const SyncButtonComponents({super.key, required this.isSendData});

  final bool isSendData;

  @override
  State<SyncButtonComponents> createState() => _SyncButtonComponentsState();
}

class _SyncButtonComponentsState extends State<SyncButtonComponents> {
  bool isLoading = false;
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "سینک داده ها",
      icon: isLoading
          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3))
          : Icon(widget.isSendData ? Icons.cloud_upload_rounded : Icons.cloud_download_rounded),
      onPressed: () async {
        try {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("درحال سینک داده ها..."),
          ));
          setState(() => isLoading = true);
          String? authKey = await SecureStorageProvider.getString(key: Constant.googleAuthKey);
          if (authKey == null) {
            if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS || UniversalPlatform.isWeb) {
              final googleSignIn = signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
              final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
              final authHeaders = await account?.authHeaders;
              log("authHeaders is $authHeaders");
              authKey = json.encode(authHeaders);
              await SecureStorageProvider.setString(key: Constant.googleAuthKey, value: authKey);
            }
            if (UniversalPlatform.isDesktop) {
              textEditingController.clear();
              final authUri = Uri(
                scheme: 'https',
                host: 'accounts.google.com',
                path: '/o/oauth2/v2/auth',
                queryParameters: {
                  'scope': [
                    'https://www.googleapis.com/auth/userinfo.email',
                    (drive.DriveApi.driveScope),
                  ].join(' '),
                  'response_type': "token id_token",
                  'redirect_uri': "https://md-assistant-project.firebaseapp.com/__/auth/handler",
                  'client_id': "687354198737-jtctv9rah2hbvqsiohfu939o3uuvvaf7.apps.googleusercontent.com",
                  'nonce': generateNonce(),
                  'prompt': "select_account consent",
                },
              );
              await launchUrl(authUri);
              ScaffoldMessenger.of(context).clearSnackBars();
              if (mounted) {
                await showMaterialModalBottomSheet(
                  context: context,
                  // isScrollControlled: true,
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "بعد از ورود به حساب کاربری گوگل خود و تکمیل عملیات، لینک مرورگر خود را کپی کنید و در فیلد زیر را وارد کنید"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: textEditingController,
                              decoration: const InputDecoration(
                                labelText: 'آدرس مرورگر',
                                hintText: "آدرس مرورگر را وارد کنید",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                                child: TextButton(
                                    onPressed: () async {
                                      if (mounted) Navigator.pop(context);
                                    },
                                    child: Text("ثبت")),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("لغو")),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              }

              // Parse the URL using the Uri class
              Uri uri = Uri.parse(textEditingController.text.trim());

              // Get the fragment part of the URL
              String fragment = uri.fragment;

              // Split the fragment string into individual key-value pairs
              List<String> keyValuePairs = fragment.split('&');

              // Create a map to store the extracted key-value pairs
              Map<String, String> queryParams = {};

              // Extract the key-value pairs and store them in the map
              for (String pair in keyValuePairs) {
                List<String> parts = pair.split('=');
                if (parts.length == 2) {
                  String key = parts[0];
                  String value = parts[1];
                  queryParams[key] = value;
                }
              }

              // Extract the needed information from the map
              String? accessToken = queryParams['access_token'];
              String? tokenType = queryParams['token_type'];
              String? expiresIn = queryParams['expires_in'];
              String? scope = queryParams['scope'];
              String? idToken = queryParams['id_token'];

              Map<String, String> jsonObject = {'Authorization': 'Bearer $accessToken'};

              authKey = json.encode(jsonObject);

              await SecureStorageProvider.setString(key: Constant.googleAuthKey, value: authKey);

            }
          }

          await AppSync.syncApplicationData(authKey ?? "", widget.isSendData);
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).clearSnackBars();
          if (widget.isSendData) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("داده های شما با موفقیت ارسال شدند."),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("داده های شما با موفقیت دریافت شدند."),
            ));
          }
        } catch (e) {
          log("ERROR IS ${e.toString()}");
          await SecureStorageProvider.deleteString(key: Constant.googleAuthKey);
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("خطایی رخ داده است. لطفا دوباره امتحان کنید"),
          ));
        }
      },
    );
  }
}

String generateNonce({int length = 32}) {
  const characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = math.Random.secure();

  return List.generate(
    length,
    (_) => characters[random.nextInt(characters.length)],
  ).join();
}
