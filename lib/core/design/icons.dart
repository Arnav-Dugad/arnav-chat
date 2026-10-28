// Phosphor icon fonts (MIT) are bundled in assets/fonts/phosphor. The
// phosphor_flutter package is not used: it subclasses IconData, which is a
// final class in current Flutter.
import 'package:flutter/widgets.dart';

/// The single icon vocabulary of the app (Phosphor, consistent 1.5px stroke).
abstract final class AppIcons {
  static const _regular = 'PhosphorRegular';
  static const _fill = 'PhosphorFill';
  static const _bold = 'PhosphorBold';

  static const IconData chats = IconData(0xe17e, fontFamily: _regular);
  static const IconData chatsFill = IconData(0xe17e, fontFamily: _fill);
  static const IconData people = IconData(0xe68e, fontFamily: _regular);
  static const IconData peopleFill = IconData(0xe68e, fontFamily: _fill);
  static const IconData settings = IconData(0xe272, fontFamily: _regular);
  static const IconData settingsFill = IconData(0xe272, fontFamily: _fill);
  static const IconData search = IconData(0xe30c, fontFamily: _regular);
  static const IconData compose = IconData(0xe3b4, fontFamily: _regular);
  static const IconData send = IconData(0xe396, fontFamily: _fill);
  static const IconData mic = IconData(0xe326, fontFamily: _regular);
  static const IconData micFill = IconData(0xe326, fontFamily: _fill);
  static const IconData attach = IconData(0xe39a, fontFamily: _regular);
  static const IconData plus = IconData(0xe3d4, fontFamily: _regular);
  static const IconData camera = IconData(0xe10e, fontFamily: _regular);
  static const IconData image = IconData(0xe2ca, fontFamily: _regular);
  static const IconData video = IconData(0xe4da, fontFamily: _regular);
  static const IconData file = IconData(0xe23a, fontFamily: _regular);
  static const IconData play = IconData(0xe3d0, fontFamily: _fill);
  static const IconData pause = IconData(0xe39e, fontFamily: _fill);
  static const IconData stop = IconData(0xe46c, fontFamily: _fill);
  static const IconData lock = IconData(0xe2fa, fontFamily: _regular);
  static const IconData lockFill = IconData(0xe2fa, fontFamily: _fill);
  static const IconData close = IconData(0xe4f6, fontFamily: _regular);
  static const IconData back = IconData(0xe138, fontFamily: _regular);
  static const IconData chevron = IconData(0xe13a, fontFamily: _regular);
  static const IconData up = IconData(0xe08e, fontFamily: _regular);
  static const IconData check = IconData(0xe182, fontFamily: _bold);
  static const IconData checks = IconData(0xe53a, fontFamily: _bold);
  static const IconData clock = IconData(0xe19a, fontFamily: _regular);
  static const IconData warning = IconData(0xe4e2, fontFamily: _fill);
  static const IconData offline = IconData(0xe4f2, fontFamily: _regular);
  static const IconData reply = IconData(0xe024, fontFamily: _regular);
  static const IconData forward = IconData(0xed52, fontFamily: _regular);
  static const IconData copy = IconData(0xe1ca, fontFamily: _regular);
  static const IconData edit = IconData(0xe3b4, fontFamily: _regular);
  static const IconData trash = IconData(0xe4a6, fontFamily: _regular);
  static const IconData star = IconData(0xe46a, fontFamily: _regular);
  static const IconData starFill = IconData(0xe46a, fontFamily: _fill);
  static const IconData pin = IconData(0xe3e2, fontFamily: _regular);
  static const IconData pinFill = IconData(0xe3e2, fontFamily: _fill);
  static const IconData archive = IconData(0xe00c, fontFamily: _regular);
  static const IconData mute = IconData(0xe0d4, fontFamily: _regular);
  static const IconData qr = IconData(0xe3e6, fontFamily: _regular);
  static const IconData scan = IconData(0xebb6, fontFamily: _regular);
  static const IconData download = IconData(0xe20c, fontFamily: _regular);
  static const IconData signOut = IconData(0xe42a, fontFamily: _regular);
  static const IconData moon = IconData(0xe330, fontFamily: _regular);
  static const IconData palette = IconData(0xe6c8, fontFamily: _regular);
  static const IconData eye = IconData(0xe220, fontFamily: _regular);
  static const IconData user = IconData(0xe4c2, fontFamily: _regular);
  static const IconData at = IconData(0xe0ac, fontFamily: _regular);
  static const IconData google = IconData(0xe292, fontFamily: _bold);
  static const IconData mail = IconData(0xe218, fontFamily: _regular);
  static const IconData smiley = IconData(0xe436, fontFamily: _regular);
  static const IconData link = IconData(0xe2e2, fontFamily: _regular);
  static const IconData heartFill = IconData(0xe2a8, fontFamily: _fill);
  static const IconData share = IconData(0xe408, fontFamily: _regular);
  static const IconData userPlus = IconData(0xe4d0, fontFamily: _regular);
  static const IconData shield = IconData(0xe40c, fontFamily: _regular);
  static const IconData info = IconData(0xe2ce, fontFamily: _regular);
  static const IconData sparkle = IconData(0xe6a2, fontFamily: _regular);
  static const IconData sun = IconData(0xe472, fontFamily: _regular);
  static const IconData poll = IconData(0xe150, fontFamily: _regular);
  static const IconData bookmark = IconData(0xe0ea, fontFamily: _regular);
  static const IconData bookmarkFill = IconData(0xe0ea, fontFamily: _fill);
  static const IconData folder = IconData(0xe25a, fontFamily: _regular);
  static const IconData crown = IconData(0xe616, fontFamily: _fill);
  static const IconData images = IconData(0xe836, fontFamily: _regular);
  static const IconData paint = IconData(0xe6f0, fontFamily: _regular);
  static const IconData sliders = IconData(0xe434, fontFamily: _regular);
  static const IconData dots = IconData(0xe1fe, fontFamily: _bold);
  static const IconData group = IconData(0xe68e, fontFamily: _fill);

}
