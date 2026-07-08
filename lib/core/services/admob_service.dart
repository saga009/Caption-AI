import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_strings.dart';

class AdmobService {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static bool _isInterstitialLoading = false;
  static bool _isRewardedLoading = false;

  static bool get adsEnabled => AppStrings.adsEnabled;

  static Future<void> initialize() async {
    if (!adsEnabled) return;

    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  static String get bannerAdUnitId => Platform.isAndroid
      ? AppStrings.bannerAdUnitAndroid
      : AppStrings.bannerAdUnitIos;

  static String get interstitialAdUnitId => Platform.isAndroid
      ? AppStrings.interstitialAdUnitAndroid
      : AppStrings.interstitialAdUnitIos;

  static String get rewardedAdUnitId => Platform.isAndroid
      ? AppStrings.rewardedAdUnitAndroid
      : AppStrings.rewardedAdUnitIos;

  static BannerAd? createBannerAd() {
    if (!adsEnabled) return null;
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  static void _loadInterstitialAd() {
    if (!adsEnabled || _isInterstitialLoading) return;
    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  static void showInterstitialAd({VoidCallback? onDismissed}) {
    if (!adsEnabled || _interstitialAd == null) {
      if (adsEnabled) _loadInterstitialAd();
      onDismissed?.call();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
        onDismissed?.call();
      },
    );
    _interstitialAd!.show();
  }

  static void _loadRewardedAd() {
    if (!adsEnabled || _isRewardedLoading) return;
    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
        },
      ),
    );
  }

  static void showRewardedAd({
    required Function(int amount) onRewarded,
    VoidCallback? onFailed,
  }) {
    if (!adsEnabled || _rewardedAd == null) {
      if (adsEnabled) _loadRewardedAd();
      onFailed?.call();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        onFailed?.call();
      },
    );
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(AppStrings.rewardedGenerations);
      },
    );
  }

  static bool get isRewardedAdReady => adsEnabled && _rewardedAd != null;
}
