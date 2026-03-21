(String, String) getTimeDifferenceText(DateTime deadline) {
  final diffInSeconds = (deadline.difference(DateTime.now()).inSeconds);
  if (diffInSeconds.abs() < 3600) {
    return ("${diffInSeconds ~/ 60}", "mins");
  }
  if (diffInSeconds.abs() < 3600 * 24) {
    return ("${diffInSeconds ~/ 3600}", "hours");
  }
  if (diffInSeconds.abs() < 3600 * 24 * 7) {
    return ("${diffInSeconds ~/ (3600 * 24)}", "days");
  }
  return ("${diffInSeconds ~/ (3600 * 24 * 7)}", "weeks");
}
