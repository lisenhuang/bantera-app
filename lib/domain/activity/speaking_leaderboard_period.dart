/// Older cached reports were always the public 30-day summary.
int speakingLeaderboardPeriodDays(Map<String, dynamic> report) {
  final days = report['periodDays'];
  return days is int && days >= 1 && days <= 365 ? days : 30;
}
