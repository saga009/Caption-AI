class AppStrings {
  static const String appName = 'Caption AI';
  static const String tagline = 'Generate viral captions instantly';

  static const String homeTitle = 'Choose Category';
  static const String inputHint = 'Describe your photo or moment...';
  static const String generateBtn = 'Generate Caption ✨';
  static const String generateAgain = 'Generate Again';
  static const String copyCaption = 'Copy Caption';
  static const String copyHashtags = 'Copy Hashtags';
  static const String share = 'Share';

  static const String shortCaption = 'Short Caption';
  static const String longCaption = 'Long Caption';
  static const String emojiCaption = 'Emoji Caption';
  static const String hashtags = 'Hashtags';

  static const String dailyLimitTitle = 'Daily Limit Reached';
  static const String dailyLimitMsg =
      "You've used all 20 free captions today. Watch an ad for 20 more!";
  static const String watchAd = 'Watch Ad for More';
  static const String copiedMsg = 'Copied to clipboard!';
  static const String generatingMsg = 'Crafting your perfect caption...';
  static const String generatingTip =
      'The more details you add to your description, the more unique your caption will be.';

  // Style & Preferences screen
  static const String styleTitle = 'Style & Preferences';
  static const String toneLabel = 'Tone';
  static const String lengthLabel = 'Caption Length';
  static const String emojiLevelLabel = 'Emoji Level';
  static const String generateCaptionBtn = 'Generate Caption ✨';

  // Navigation
  static const String navHome = 'Home';
  static const String navTools = 'Tools';
  static const String navHistory = 'History';
  static const String navFavorites = 'Favorites';
  static const String navSettings = 'Settings';

  // Tools screen
  static const String toolsTitle = 'All Categories';
  static const String searchHint = 'Search a category...';

  // History / Favorites
  static const String historyTitle = 'History';
  static const String favoritesTitle = 'Favorites';
  static const String historyEmpty = 'No captions generated yet';
  static const String historyEmptySub = 'Your generated captions will show up here';
  static const String favoritesEmpty = 'No favorites yet';
  static const String favoritesEmptySub = 'Tap the heart on a caption to save it here';
  static const String deleteEntry = 'Delete';
  static const String deleteEntryConfirm = 'Delete this caption from your history?';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String clearHistory = 'Clear History';
  static const String clearHistoryConfirm =
      'This will permanently delete all your saved captions. This cannot be undone.';
  static const String shareApp = 'Share App';
  static const String appVersion = 'App Version';

  // Set to false to disable all ads app-wide (flip before a Play Store build).
  static const bool adsEnabled = false;

  // AdMob IDs (test IDs - replace with real ones before publishing)
  static const String admobAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const String admobAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  static const String bannerAdUnitAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String bannerAdUnitIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String interstitialAdUnitAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String interstitialAdUnitIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String rewardedAdUnitAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String rewardedAdUnitIos = 'ca-app-pub-3940256099942544/1712485313';
  static const String appOpenAdUnitAndroid = 'ca-app-pub-3940256099942544/9257395921';
  static const String appOpenAdUnitIos = 'ca-app-pub-3940256099942544/5575463023';

  // Groq (free AI API — get key at console.groq.com)
  static const String groqApiKey = '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';
  static const String groqModel = 'llama-3.3-70b-versatile';

  static const int freeGenerationsPerDay = 20;
  static const int rewardedGenerations = 20;
}
