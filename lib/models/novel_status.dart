enum NovelStatus {
  bucketList,
  reading,
  onHold,
  completed,
  dropped;

  String get displayName {
    switch (this) {
      case NovelStatus.bucketList:
        return 'Bucket List';
      case NovelStatus.reading:
        return 'Reading';
      case NovelStatus.onHold:
        return 'On Hold';
      case NovelStatus.completed:
        return 'Completed';
      case NovelStatus.dropped:
        return 'Dropped';
    }
  }
}
