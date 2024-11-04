import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/permission_helper.dart';
import 'package:smooth_app/pages/scan/camera_scan_page.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class ScanPage extends StatefulWidget {
  const ScanPage();

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  /// Audio player to play the beep sound on scan
  AudioPlayer? _musicPlayer;
  late UserPreferences _userPreferences;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      _userPreferences = context.watch<UserPreferences>();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<ContinuousScanModel?>() == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool hasACamera = CameraHelper.hasACamera;

    return SmoothScaffold(
      brightness: Theme.of(context).brightness == Brightness.light && Platform.isIOS
          ? Brightness.dark
          : null,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: hasACamera
                ? Consumer<PermissionListener>(
                    builder: (
                      BuildContext context,
                      PermissionListener listener,
                      _,
                    ) {
                      switch (listener.value.status) {
                        case DevicePermissionStatus.checking:
                          return EMPTY_WIDGET;
                        case DevicePermissionStatus.granted:
                          return const CameraScannerPage();
                        default:
                          return const _PermissionDeniedCard();
                      }
                    },
                  )
                : Center(
                    child: Text(appLocalizations.permission_photo_none_found),
                  ),
          ),
        ),
      ),
    );
  }

  /// Only initialize the "beep" player when needed
  /// (at least one camera available + settings set to ON)
  Future<void> _initSoundManagerIfNecessary() async {
    if (_musicPlayer != null) {
      return;
    }

    _musicPlayer = AudioPlayer(playerId: '1');
  }

  Future<void> _disposeSoundManager() async {
    await _musicPlayer?.release();
    await _musicPlayer?.dispose();
    _musicPlayer = null;
  }

  @override
  void dispose() {
    _disposeSoundManager();
    super.dispose();
  }
}

class _PermissionDeniedCard extends StatelessWidget {
  const _PermissionDeniedCard();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            alignment: Alignment.topCenter,
            constraints: BoxConstraints.tightForFinite(
              width: constraints.maxWidth,
              height: math.min(constraints.maxHeight * 0.9, 200),
            ),
            child: SmoothCard(
              padding: const EdgeInsetsDirectional.only(
                top: BALANCED_SPACE,
                start: SMALL_SPACE,
                end: SMALL_SPACE,
                bottom: 5.0,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    Text(
                      localizations.permission_photo_denied_title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BALANCED_SPACE,
                            vertical: BALANCED_SPACE,
                          ),
                          child: Text(
                            localizations.permission_photo_denied_message(
                              APP_NAME,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              height: 1.4,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SmoothActionButtonsBar.single(
                      action: SmoothActionButton(
                        text: localizations.permission_photo_denied_button,
                        onPressed: () => _askPermission(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _askPermission(BuildContext context) {
    return Provider.of<PermissionListener>(
      context,
      listen: false,
    ).askPermission(onRationaleNotAvailable: () async {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            final AppLocalizations localizations = AppLocalizations.of(context);

            return SmoothAlertDialog(
              title:
                  localizations.permission_photo_denied_dialog_settings_title,
              body: Text(
                localizations.permission_photo_denied_dialog_settings_message,
                style: const TextStyle(
                  height: 1.6,
                ),
              ),
              negativeAction: SmoothActionButton(
                text: localizations
                    .permission_photo_denied_dialog_settings_button_cancel,
                onPressed: () => Navigator.of(context).pop(false),
                lines: 2,
              ),
              positiveAction: SmoothActionButton(
                text: localizations
                    .permission_photo_denied_dialog_settings_button_open,
                onPressed: () => Navigator.of(context).pop(true),
                lines: 2,
              ),
              actionsAxis: Axis.vertical,
            );
          });
    });
  }
}
