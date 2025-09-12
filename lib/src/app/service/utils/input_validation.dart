bool isValidMobile(String input) {
  final mobileRegex = RegExp(r'^\d{10}$');
  return mobileRegex.hasMatch(input);
}

bool isValidEmail(String input) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(input);
}

String? getYoutubeVideoId(String? url) => url == null
    ? null
    : RegExp(
        r"(?:v=|\/)([0-9A-Za-z_-]{11})(?:\?|\&|$)",
      ).firstMatch(url)?.group(1);
