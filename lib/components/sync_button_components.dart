import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:md_assistant/providers/secure_storage_provider.dart';
import 'package:md_assistant/service/app_sync.dart';
import 'package:md_assistant/utils/constant.dart';

class SyncButtonComponents extends StatefulWidget {
  const SyncButtonComponents({super.key, required this.isSendData});

  final bool isSendData;

  @override
  State<SyncButtonComponents> createState() => _SyncButtonComponentsState();
}

class _SyncButtonComponentsState extends State<SyncButtonComponents> {
  bool isLoading = false;

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
            log("Start LOGIN");
            final googleSignIn = signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
            final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
            log("Start LOGIN");
            final authHeaders = await account?.authHeaders;
            log("authHeaders is ${authHeaders}");
            authKey = json.encode(authHeaders);
            await SecureStorageProvider.setString(key: Constant.googleAuthKey, value: authKey);
          }

          await AppSync.syncApplicationData(authKey, widget.isSendData);
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
