import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/blur_fade.dart';

/// AddressSearchPage — keyboard-first address search.
///
/// Reference: `app/address/page.tsx`. Renders a search input at the top
/// (focused on mount), a polka-dot "map preview" panel, and a list of
/// suggested + saved addresses. Selecting a suggestion takes the user
/// to confirmation (deferred to a later phase — this screen stubs the
/// behavior so the route is no longer a placeholder).
///
/// Network integration: the Places autocomplete call would slot in via a
/// repository/notifier in the data layer. The route guard / data layer
/// constraint forbids that edit in this phase, so we render a small set
/// of inline suggestions and indicate where the Places call will land
/// via a clear TODO.
class AddressSearchPage extends ConsumerStatefulWidget {
  const AddressSearchPage({super.key});

  @override
  ConsumerState<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends ConsumerState<AddressSearchPage> {
  final _query = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  // TODO(phase-store): replace with Places autocomplete via repository.
  List<_Suggestion> _suggestionsFor(String q) {
    if (q.trim().isEmpty) return const [];
    final lower = q.toLowerCase();
    final pool = [
      _Suggestion(
        primary: 'Connaught Place',
        secondary: 'Block A, New Delhi, 110001',
      ),
      _Suggestion(
        primary: 'Indiranagar',
        secondary: '100 Feet Rd, Bengaluru, 560038',
      ),
      _Suggestion(
        primary: 'Bandra West',
        secondary: 'Linking Rd, Mumbai, 400050',
      ),
      _Suggestion(
        primary: 'Anna Nagar',
        secondary: '2nd Avenue, Chennai, 600040',
      ),
      _Suggestion(
        primary: 'Sector 29',
        secondary: 'Leisure Valley, Gurugram, 122001',
      ),
    ];
    return pool
        .where((s) =>
            s.primary.toLowerCase().contains(lower) ||
            s.secondary.toLowerCase().contains(lower))
        .toList();
  }

  void _onSuggestionTap(_Suggestion s) {
    HapticFeedback.selectionClick();
    FocusManager.instance.primaryFocus?.unfocus();
    context.push(
      '/location/search/detail',
      extra: {'title': s.primary, 'subtitle': s.secondary},
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final query = _query.text;
    final suggestions = _suggestionsFor(query);

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    _BackCircle(onTap: () => context.pop()),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: BlurFade(
                        child: _SearchInput(
                          controller: _query,
                          focusNode: _focus,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (query.trim().isEmpty)
                Expanded(child: const _MapPreviewPanel())
              else
                Expanded(
                  child: suggestions.isEmpty
                      ? const _EmptyState()
                      : _SuggestionsList(
                          suggestions: suggestions,
                          onTap: _onSuggestionTap,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Suggestion {
  const _Suggestion({required this.primary, required this.secondary});
  final String primary;
  final String secondary;
}

class _BackCircle extends StatelessWidget {
  const _BackCircle({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_back_rounded,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.ctaLg),
        border: Border.all(color: AppColors.border, width: 1.4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.inputLg.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search address, landmark, area',
                hintStyle: AppTypography.inputLg.copyWith(
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreviewPanel extends StatelessWidget {
  const _MapPreviewPanel();

  @override
  Widget build(BuildContext context) {
    return BlurFade(
      delay: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const RepaintBoundary(
              child: CustomPaint(painter: _PolkaDotPainter()),
            ),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.brandGlow,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.lg,
              child: Center(
                child: Text(
                  'Type an address to search',
                  style: AppTypography.captionMd.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolkaDotPainter extends CustomPainter {
  const _PolkaDotPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.border;
    const step = 24.0;
    for (double y = step / 2; y < size.height; y += step) {
      for (double x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PolkaDotPainter old) => false;
}

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({required this.suggestions, required this.onTap});
  final List<_Suggestion> suggestions;
  final ValueChanged<_Suggestion> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      itemCount: suggestions.length,
      separatorBuilder: (_, i) => Divider(
        height: 1,
        color: AppColors.border.withValues(alpha: 0.6),
      ),
      itemBuilder: (context, i) {
        final s = suggestions[i];
        return BlurFade(
          delay: Duration(milliseconds: 100 + 80 * i),
          child: InkWell(
            onTap: () => onTap(s),
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.brandLight,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.primary,
                          style: AppTypography.buttonLabel.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.secondary,
                          style: AppTypography.captionMd.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No matches',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a nearby landmark or pin code.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
