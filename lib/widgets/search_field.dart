import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/weather.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import 'google_surface_card.dart';

/// Google-style pill search bar with animated results.
class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.smooth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: _focusNode.hasFocus ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search for a city',
              prefixIcon: Icon(
                Icons.search,
                color: _focusNode.hasFocus
                    ? AppColors.googleBlue
                    : AppColors.onSurfaceVariant,
              ),
              suffixIcon: AnimatedSwitcher(
                duration: AppMotion.fast,
                child: _controller.text.isNotEmpty
                    ? IconButton(
                        key: const ValueKey('clear'),
                        icon: const Icon(Icons.close, size: 20),
                        color: AppColors.onSurfaceVariant,
                        onPressed: () {
                          _controller.clear();
                          context.read<WeatherProvider>().clearSearch();
                          setState(() {});
                        },
                      )
                    : const SizedBox(
                        key: ValueKey('empty'),
                        width: 0,
                        height: 0,
                      ),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 16,
            ),
            onChanged: (value) {
              setState(() {});
              context.read<WeatherProvider>().searchCities(value);
            },
            onSubmitted: (_) => _pickFirstResult(context),
          ),
        ),
        Consumer<WeatherProvider>(
          builder: (context, provider, _) {
            return AnimatedSize(
              duration: AppMotion.medium,
              curve: AppMotion.smooth,
              alignment: Alignment.topCenter,
              child: _buildResultsPanel(context, provider),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultsPanel(BuildContext context, WeatherProvider provider) {
    if (provider.searchError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Text(
          provider.searchError!,
          style: TextStyle(
            color: Colors.orange.shade100,
            fontSize: 13,
          ),
        ),
      );
    }

    if (provider.searchResults.isEmpty) {
      return const SizedBox(width: double.infinity);
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: GoogleSurfaceCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.searchResults.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: AppColors.divider,
          ),
          itemBuilder: (context, index) {
            final city = provider.searchResults[index];
            return _SearchResultTile(
              city: city,
              index: index,
              onTap: () => _selectCity(context, city),
            );
          },
        ),
      ),
    );
  }

  void _pickFirstResult(BuildContext context) {
    final results = context.read<WeatherProvider>().searchResults;
    if (results.isNotEmpty) {
      _selectCity(context, results.first);
    }
  }

  void _selectCity(BuildContext context, CityLocation city) {
    FocusScope.of(context).unfocus();
    _controller.clear();
    setState(() {});
    context.read<WeatherProvider>().loadWeather(city);
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.city,
    required this.index,
    required this.onTap,
  });

  final CityLocation city;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: AppMotion.staggerStep * index,
      duration: AppMotion.fast,
      offsetY: 8,
      child: ListTile(
        leading: const Icon(
          Icons.location_on_outlined,
          color: AppColors.googleBlue,
          size: 22,
        ),
        title: Text(
          city.displayName,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
