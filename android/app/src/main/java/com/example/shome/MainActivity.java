package com.example.shome;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.telephony.SmsManager;
import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.io.File;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.shome/installer";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "sendSms":
                            String phone = call.argument("phone");
                            String message = call.argument("message");
                            if (phone == null || message == null) {
                                result.error("INVALID_ARGS", "Phone or message is null", null);
                                return;
                            }
                            try {
                                SmsManager smsManager;
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                    smsManager = getSystemService(SmsManager.class);
                                } else {
                                    smsManager = SmsManager.getDefault();
                                }
                                smsManager.sendTextMessage(phone, null, message, null, null);
                                result.success(true);
                            } catch (Exception e) {
                                result.error("SMS_ERROR", e.getMessage(), null);
                            }
                            break;

                        case "installApk":
                            String path = call.argument("path");
                            if (path == null) {
                                result.error("INVALID_PATH", "Path is null", null);
                                return;
                            }
                            try {
                                installApk(path);
                                result.success(true);
                            } catch (Exception e) {
                                result.error("INSTALL_ERROR", e.getMessage(), null);
                            }
                            break;

                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

    private void installApk(String filePath) {
        File file = new File(filePath);
        if (!file.exists()) {
            throw new RuntimeException("File not found: " + filePath);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (!getPackageManager().canRequestPackageInstalls()) {
                Intent settingsIntent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
                        .setData(Uri.parse("package:" + getPackageName()))
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(settingsIntent);
                throw new RuntimeException("Разрешите установку из неизвестных источников");
            }
        }

        Uri uri = FileProvider.getUriForFile(
                this,
                getApplicationId() + ".fileprovider",
                file
        );

        Intent intent = new Intent(Intent.ACTION_INSTALL_PACKAGE);
        intent.setData(uri);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(Intent.EXTRA_NOT_UNKNOWN_SOURCE, true);
        intent.putExtra(Intent.EXTRA_RETURN_RESULT, true);
        startActivity(intent);
    }

    private String getApplicationId() {
        try {
            return getPackageName();
        } catch (Exception e) {
            return "com.example.shome";
        }
    }
}