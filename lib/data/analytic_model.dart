class AnalyticItem {
  final String location;
  final String ip;
  final String device;
  final String osName;
  final String landedAt;
  final String guid;
  final String timeSpent;
  final String url;
  final bool isNew;
  final String browser;
  final String key;
  final String country_code;

  AnalyticItem(this.location, this.ip, this.device, this.osName, this.landedAt,
      this.guid, this.timeSpent, this.url, this.isNew, this.browser, this.key, this.country_code);
}
