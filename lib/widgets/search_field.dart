import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/weather.dart';
import '../providers/weather_provider.dart';

/// StatelessWidget — like a functional React component with props.
class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search city (e.g. Paris, Tokyo)',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
          onChanged: (value) {
            context.read<WeatherProvider>().searchCities(value);
          },
          onSubmitted: (_) => _pickFirstResult(context),
        ),
        const SizedBox(height: 8),
        Consumer<WeatherProvider>(
          builder: (context, provider, _) {
            if (provider.searchResults.isEmpty) {
              return const SizedBox.shrink();
            }
            return Material(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.searchResults.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final city = provider.searchResults[index];
                  return ListTile(
                    title: Text(
                      city.displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => _selectCity(context, city),
                  );
                },
              ),
            );
          },
        ),
      ],
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
    context.read<WeatherProvider>().loadWeather(city);
  }
}
