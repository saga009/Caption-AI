import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/caption_provider.dart';
import '../../core/providers/generation_limit_provider.dart';
import '../../core/services/admob_service.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onGenerate() async {
    final description = _textController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your photo first')),
      );
      return;
    }

    final limitProvider = context.read<GenerationLimitProvider>();
    final captionProvider = context.read<CaptionProvider>();

    final canGen = await limitProvider.tryGenerate();

    if (!canGen && mounted) {
      _showLimitDialog();
      return;
    }

    captionProvider.setDescription(description);

    final genCount = captionProvider.generateCount;
    if (genCount > 0 && genCount % 3 == 0) {
      AdmobService.showInterstitialAd(onDismissed: () {
        if (mounted) _navigate(captionProvider);
      });
    } else {
      await _navigate(captionProvider);
    }
  }

  Future<void> _navigate(CaptionProvider captionProvider) async {
    await captionProvider.generateCaption();
    if (mounted) {
      Navigator.pushNamed(context, '/result');
    }
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppStrings.dailyLimitTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          AppStrings.dailyLimitMsg,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _watchRewardedAd();
            },
            child: const Text(AppStrings.watchAd),
          ),
        ],
      ),
    );
  }

  void _watchRewardedAd() {
    AdmobService.showRewardedAd(
      onRewarded: (amount) async {
        await context.read<GenerationLimitProvider>().addBonusGenerations(amount);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$amount bonus captions unlocked!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      onFailed: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad not available. Try again later.')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final captionProvider = context.watch<CaptionProvider>();
    final category = captionProvider.selectedCategory;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category != null) _buildCategoryBadge(context, category.emoji, category.name),
                      const SizedBox(height: 24),
                      _buildLabel(context, 'Describe your photo or moment'),
                      const SizedBox(height: 12),
                      _buildTextField(),
                      const SizedBox(height: 12),
                      _buildSuggestions(context),
                      const SizedBox(height: 32),
                      _buildGenerateButton(context, captionProvider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
          Text(
            'Describe Your Photo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context, String emoji, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppColors.textPrimary,
          ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      maxLines: 5,
      maxLength: 300,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: AppStrings.inputHint,
        counterStyle: const TextStyle(color: AppColors.textMuted),
      ),
      onChanged: (v) => context.read<CaptionProvider>().setDescription(v),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final category = context.read<CaptionProvider>().selectedCategory;
    final List<String> examples = _getExamples(category?.id ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try these examples:',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: examples
              .map(
                (e) => GestureDetector(
                  onTap: () {
                    _textController.text = e;
                    context.read<CaptionProvider>().setDescription(e);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      e,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(BuildContext context, CaptionProvider captionProvider) {
    final isLoading = captionProvider.state == CaptionState.loading;

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _onGenerate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.generatingMsg,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                )
              : Text(
                  AppStrings.generateBtn,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                ),
        ),
      ),
    );
  }

  List<String> _getExamples(String categoryId) {
    const examples = {
      'selfie': ['Mirror selfie after haircut', 'Golden hour selfie on rooftop', 'No makeup, just me'],
      'travel': ['Sunset at Nainital Lake', 'Exploring old streets of Jaipur', 'Mountains in Manali'],
      'gym': ['Gym workout after 3 months', 'First pull-up achieved today', 'Post workout selfie'],
      'bike': ['New bike delivery today', 'Morning ride on highway', 'Road trip on Royal Enfield'],
      'love': ['Anniversary dinner surprise', 'First trip together', 'Coffee date on rainy day'],
      'nature': ['Misty morning in forest', 'Rainbow after the rain', 'Cherry blossoms in full bloom'],
      'linkedin': ['Got promoted to senior role', 'Completed 5 years at company', 'New job joining day'],
      'birthday': ['Turning 25 today!', 'Surprise birthday party', 'Birthday cake cutting'],
      'attitude': ['New outfit, new energy', 'Living life on my terms', 'Saturday vibes only'],
      'funny': ['Caught sleeping in office', 'Pizza is my best friend', 'Monday face vs Friday face'],
    };
    return examples[categoryId] ?? ['Beautiful moment', 'Loving life', 'Just vibes'];
  }
}
