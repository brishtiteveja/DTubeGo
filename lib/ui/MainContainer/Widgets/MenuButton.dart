import 'package:dtube_go/ui/MainContainer/Widgets/AboutDialog.dart';
import 'package:dtube_go/ui/widgets/dtubeLogoPulse/DTubeLogo.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:dtube_go/bloc/notification/notification_bloc_full.dart';
import 'package:dtube_go/bloc/settings/settings_bloc_full.dart';
import 'package:dtube_go/res/appConfigValues.dart';
import 'package:dtube_go/style/ThemeData.dart';
import 'package:dtube_go/ui/widgets/DialogTemplates/DialogWithTitleLogo.dart';
import 'package:dtube_go/ui/pages/settings/SettingsTabContainer.dart';
import 'package:dtube_go/ui/pages/wallet/WalletTabContainer.dart';
import 'package:dtube_go/ui/widgets/OverlayWidgets/OverlayIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildMainMenuSpeedDial(BuildContext context) {
  List<SpeedDialChild> mainMenuButtonOptions = [
    SpeedDialChild(
        child: ShadowedIcon(
            icon: FontAwesomeIcons.wallet,
            color: Colors.white,
            shadowColor: Colors.black,
            size: globalIconSizeMedium),
        foregroundColor: Colors.white,
        elevation: 0,
        backgroundColor: Colors.transparent,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BlocProvider<NotificationBloc>(
                create: (context) =>
                    NotificationBloc(repository: NotificationRepositoryImpl()),
                child: WalletMainPage());
          }));
        }),
    SpeedDialChild(
        child: ShadowedIcon(
            icon: FontAwesomeIcons.question,
            color: Colors.white,
            shadowColor: Colors.black,
            size: globalIconSizeMedium),
        foregroundColor: Colors.white,
        elevation: 0,
        backgroundColor: Colors.transparent,
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AboutAppDialog();
              });
        }),
    SpeedDialChild(
        child: ShadowedIcon(
            icon: FontAwesomeIcons.cog,
            color: Colors.white,
            shadowColor: Colors.black,
            size: globalIconSizeMedium),
        foregroundColor: Colors.white,
        elevation: 0,
        backgroundColor: Colors.transparent,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BlocProvider<SettingsBloc>(
                create: (context) => SettingsBloc(),
                child: SettingsTabContainer());
          }));
        }),
  ];

  return SpeedDial(
      child: ShadowedIcon(
          icon: FontAwesomeIcons.bars,
          color: Colors.white,
          shadowColor: Colors.black,
          size: globalIconSizeMedium),
      activeIcon: FontAwesomeIcons.chevronLeft,
      direction: SpeedDialDirection.down,
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.white,
      overlayOpacity: 0,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'menu',
      heroTag: 'main menu button',
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0.0,
      shape: CircleBorder(),
      gradientBoxShape: BoxShape.circle,
      children: mainMenuButtonOptions);
}
