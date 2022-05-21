/*
 * Copyright 2020 Son Nguyen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdmobConsent {
  final MethodChannel _channel;

  final _onConsentFormLoaded = StreamController<void>.broadcast();
  final _onConsentFormOpened = StreamController<void>.broadcast();
  final _onConsentFormObtained = StreamController<void>.broadcast();
  final _onConsentFormError = StreamController<dynamic>.broadcast();

  static AdmobConsent? _instance;

  factory AdmobConsent() {
    if (_instance == null) {
      const MethodChannel methodChannel = const MethodChannel('admob_consent');
      _instance = AdmobConsent.private(methodChannel);
    }
    return _instance!;
  }

  @visibleForTesting
  AdmobConsent.private(this._channel) {
    _channel.setMethodCallHandler(_handleMessages);
  }

  /// Handles calls from the native side
  Future<void> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'onConsentFormLoaded':
        _onConsentFormLoaded.add(null);
        break;
      case 'onConsentFormOpened':
        _onConsentFormOpened.add(null);
        break;
      case 'onConsentFormObtained':
        _onConsentFormObtained.add(null);
        break;
      case 'onConsentFormError':
        _onConsentFormError.add(call.arguments['message']);
        break;
    }
  }

  /// Shows admob consent form for the given publisherId
  Future<void> show({bool forceShow = false}) async =>
      await _channel.invokeMethod('show', {'forceShow': forceShow});

  /// Triggered when the form has been loaded
  Stream<void> get onConsentFormLoaded => _onConsentFormLoaded.stream;

  /// Triggered when the consent form has been opened
  Stream<void> get onConsentFormOpened => _onConsentFormOpened.stream;

  /// Triggered when the consent form has been opened
  Stream<void> get onConsentFormObtained => _onConsentFormObtained.stream;

  /// Returns error message when an error has occurred
  Stream<dynamic> get onConsentFormError => _onConsentFormError.stream;

  /// Dispose the admob consent instance
  void dispose() {
    _onConsentFormLoaded.close();
    _onConsentFormOpened.close();
    _onConsentFormObtained.close();
    _onConsentFormError.close();
    _instance = null;
  }
}
