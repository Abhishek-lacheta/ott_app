class Formatters {
  Formatters._();

  /// Formats raw counts (e.g., likes, comments, shares) into compact social media notation.
  /// 950 -> "950"
  /// 14200 -> "14.2K"
  /// 1200000 -> "1.2M"
  static String formatCount(int count) {
    if (count < 0) return '0';
    if (count < 1000) return count.toString();
    if (count < 1000000) {
      final double result = count / 1000.0;
      return '${result.toStringAsFixed(result < 10 ? 1 : 0)}K';
    }
    final double result = count / 1000000.0;
    return '${result.toStringAsFixed(result < 10 ? 1 : 0)}M';
  }

  /// Formats duration into mm:ss
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

