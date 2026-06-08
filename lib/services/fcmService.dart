import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class FCMService {
  static const String projectId = 'pingme-7539a';

  static Future<void> sendPushNotification({
    required String receiverToken,
    required String title,
    required String body,
    required String chatId,
    required String senderId,
  }) async {
    final serviceAccount = {
      "type": "service_account",
      "project_id": "pingme-7539a",
      "private_key_id": "e88633afb20cfb53dbfbdce64e1327a69833140b",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC38jfCpkSty26b\nPoqev60C5JpQGZACDjeIculPoBgoi8vsRUcnvs5jfqcK11+oaBblSIJlnenGKSVo\n5YIwloFXGdsYEhUw8X+49yn/YPc+uHS9YFmLLSJKOUVUQ3Ct+4YWZmO3RbacvXFN\n6bz1zJ+d6P/o8hKJgWi6IE8SLO+fwnc973wDhY/WWBft+4M6kh08RCmtCiMvuSxe\nwFeCYDnOi2943YUVDf4VoCSB9b+CLrWrnqJeMspc7kqpbbeSfINCno2FFpGNAE7t\nxrwABNxXl+tlANUsnidKOtpB2dSJHU55oCPOQ8e/IyNmJM+IW7+6i6svKXFQLl5P\n2TYfDjSRAgMBAAECggEAAz5ZipyDM0PWL1Vc3SQA3V9R08YBnrGou8aX89wdNPDT\nH5dQpAQmsEUyVZv63zW3qqMazococUK2OslqQGhU/0fQz9W4yzBE+epc0piff3sB\n7vlxFsXM2B12qh/Wz7CS2pgDW97WM6EZC4BKwVRSf7a1NYK4PjW6lqadclL5xjnA\nTSw+JPLoDjVMSTDRphn7GzLycB+pJxawJkEUNVV+XjZomINFqXnfCENbzftsLFxR\nzFy71UAS8pDczyRSq3aYb7R2pUHiKUwKwU3zYRlD1ToD5CDyHteoTbIEpJWt88n8\nNqePHtAstELF5BR2CgFyoF0Bw83HlEpSKnO55XgOKQKBgQDxvwZz3FAhAeFPDr6/\nNeN4SzWJ+MHIpSZWFAZi7EIuZtVhlXpDOrCxuA6s8gewzJ5wjWrXaD2Hk5vNjprU\nqgcFRU8IQNOsbNwYPnONgXZ5+YXQ1+9P7oQlm7Gi/HOPlF9nReI1PfY+K7EvP1/R\nOxrFIpYc9cGcAG6NjCPnDYjoiQKBgQDCyr7C1Cc6BrMYn6LsoWHsQrR89umB48zo\nMV3WQboXixgJ3OHK3d+xEwWA5szuxkpQ37miQlJeTsAIalmIRL+dUvrgLnZcvKGy\nMQKPpl7+Nlcxh7Rz0RPMmo4gEj0j+8LqIlHLXpaU3D+3iqCGr4DN4ypHIQATGf8D\n52znWfhZyQKBgBwpyAOpcABYaro+GoTGL2jtQiB/xXutmci/bnsJ0S/8tPE4a9T3\nOmyJ59PIIpM7U14Da6YKs9henvEUov8Ri93WVD2+56oXyJBefjHHGlldc3SAI5Yp\nUGXdPJWjWYcpnu+2GYNgY5acmnjJpk0G2LiMrfZTvymAd2CwKeKaFhAZAoGBAMAA\nQ+OaZkflzqaYw2jm8bSFU45RenzTY2gDMPE9vAX0zm76T309EX5it2wFEz7QKPRq\ncXmkUbgve01QNowA57ZU0oAii/yA2gjgEhwx6zQ7r9pcXtxB23gzZ5/pGmbbg5Zw\n2ZrR0y9LoWpytCPN3fIS1dtihcZOO3VHqaqongkxAoGBAMxO83k7qHHdx1v+vrAH\nJq77qgZyiz2lxlecKg2kb0SVfmBbzupCVyVcia6RP+1midzJR2dEkmcRQU3DAdy9\nQ6fafl43tYDDvnK/C33LVFjJqHGxK1fenC1rSdNCLASC6AbMGP49sny8t9nQ0pJM\n+AUHLGjEKLNBsPQZCq0XYqO4\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-fbsvc@pingme-7539a.iam.gserviceaccount.com",
      "client_id": "101975558632768423241",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
    };

    final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

    final client = await clientViaServiceAccount(credentials, [
      'https://www.googleapis.com/auth/firebase.messaging',
    ]);

    final accessToken = client.credentials.accessToken.data;

    final url =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "message": {
          "token": receiverToken,
          "notification": {"title": title, "body": body},
          "data": {"chatId": chatId, "senderId": senderId},
        },
      }),
    );

    client.close();
  }
}
