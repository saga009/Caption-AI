import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/caption_model.dart';
import '../../core/providers/caption_provider.dart';
import '../../core/providers/history_provider.dart';
import '../../core/services/admob_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  int _activeTab = 0;
  String? _currentEntryId;
  bool _entryIdRead = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_entryIdRead) {
      _entryIdRead = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) _currentEntryId = args;
    }
  }

  void _loadBannerAd() {
    final ad = AdmobService.createBannerAd();
    if (ad == null) return;
    _bannerAd = ad
      ..load().then((_) {
        if (mounted) setState(() => _bannerLoaded = true);
      });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('$label copied!'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareCaption(CaptionModel caption) {
    final text = '''
${caption.shortCaption}

${caption.longCaption}

${caption.emojiCaption}

${caption.hashtagsString}

Generated with ${AppStrings.appName} ✨
''';
    Share.share(text.trim());
  }

  void _toggleFavorite() {
    final id = _currentEntryId;
    if (id == null) return;
    context.read<HistoryProvider>().toggleFavorite(id);
  }

  Future<void> _generateAgain() async {
    final captionProvider = context.read<CaptionProvider>();
    final genCount = captionProvider.generateCount;

    Future<void> doRegenerate() async {
      await captionProvider.generateCaption();
      if (!mounted) return;
      final caption = captionProvider.caption;
      final category = captionProvider.selectedCategory;
      if (captionProvider.state == CaptionState.success && caption != null && category != null) {
        final entry = await context.read<HistoryProvider>().addEntry(
              category: category,
              description: captionProvider.description,
              caption: caption,
            );
        if (mounted) setState(() => _currentEntryId = entry.id);
      }
    }

    if (genCount > 0 && genCount % 3 == 0) {
      AdmobService.showInterstitialAd(onDismissed: doRegenerate);
    } else {
      await doRegenerate();
    }
  }

  void _showMoreActions(CaptionModel caption) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.tune, color: AppColors.primaryLight),
              title: const Text('Change Style'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.tag, color: AppColors.primaryLight),
              title: const Text('Copy Hashtags'),
              onTap: () {
                Navigator.pop(sheetContext);
                _copyToClipboard(caption.hashtagsString, 'Hashtags');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CaptionProvider>(
      builder: (context, captionProvider, _) {
        final caption = captionProvider.caption;
        final isRegenerating = captionProvider.state == CaptionState.loading;

        if (caption == null) {
          if (isRegenerating) return _buildLoadingScreen();
          return _buildErrorScreen(captionProvider.errorMessage ?? 'No caption generated');
        }
        return _buildResultScreen(caption, isRegenerating);
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.generatingMsg,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 60),
                  const SizedBox(height: 16),
                  Text('Something went wrong', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(CaptionModel caption, bool isRegenerating) {
    final tabs = ['Short', 'Long', 'Emoji', 'Tags'];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, caption),
              _buildTabBar(tabs),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCaptionCard(caption),
                      const SizedBox(height: 20),
                      _buildActionButtons(caption),
                      const SizedBox(height: 16),
                      _buildGenerateAgainButton(isRegenerating),
                    ],
                  ),
                ),
              ),
              if (_bannerLoaded && _bannerAd != null) _buildBannerAd(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, CaptionModel caption) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Your Captions ✨', style: Theme.of(context).textTheme.titleLarge),
          ),
          Consumer<HistoryProvider>(
            builder: (context, historyProvider, _) {
              final isFavorite = _currentEntryId != null && historyProvider.isFavorite(_currentEntryId!);
              return IconButton(
                onPressed: _currentEntryId == null ? null : _toggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.secondary : AppColors.textMuted,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => _showMoreActions(caption),
            icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(List<String> tabs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _activeTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isActive ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textMuted,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCaptionCard(CaptionModel caption) {
    final contents = [
      (label: AppStrings.shortCaption, text: caption.shortCaption, icon: Icons.short_text),
      (label: AppStrings.longCaption, text: caption.longCaption, icon: Icons.article_outlined),
      (label: AppStrings.emojiCaption, text: caption.emojiCaption, icon: Icons.emoji_emotions_outlined),
      (label: AppStrings.hashtags, text: caption.hashtagsString, icon: Icons.tag),
    ];

    final item = contents[_activeTab];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(item.label, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              GestureDetector(
                onTap: () => _copyToClipboard(item.text, item.label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy, color: AppColors.primaryLight, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.text,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                  fontSize: _activeTab == 2 ? 28 : 15,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CaptionModel caption) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.copy,
            label: 'Copy All',
            onTap: () => _copyToClipboard(
              '${caption.shortCaption}\n\n${caption.longCaption}\n\n${caption.emojiCaption}\n\n${caption.hashtagsString}',
              'Caption',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.tag,
            label: 'Copy Tags',
            onTap: () => _copyToClipboard(caption.hashtagsString, 'Hashtags'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.share,
            label: 'Share',
            onTap: () => _shareCaption(caption),
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateAgainButton(bool isRegenerating) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isRegenerating ? null : _generateAgain,
        icon: isRegenerating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
              )
            : const Icon(Icons.refresh, size: 18),
        label: Text(isRegenerating ? 'Regenerating...' : AppStrings.generateAgain),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBannerAd() {
    return Container(
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary ? null : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
