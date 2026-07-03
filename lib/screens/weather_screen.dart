import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const AcadesAppBar(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Weather Alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lilongwe, Malawi',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Current weather card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.homeGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primaryBorder, width: 0.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.wb_sunny_outlined,
                            color: AppColors.primary, size: 48),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '26°C',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w300,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Partly Cloudy',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Good day for field work',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '5-Day Forecast',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._forecastData.map((f) => _ForecastRow(data: f)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _forecastData = [
    _ForecastData('Monday', Icons.wb_sunny_outlined, '28°C', 'Sunny'),
    _ForecastData('Tuesday', Icons.cloud_outlined, '24°C', 'Cloudy'),
    _ForecastData('Wednesday', Icons.grain_outlined, '22°C', 'Rain — 20mm'),
    _ForecastData('Thursday', Icons.wb_cloudy_outlined, '23°C', 'Overcast'),
    _ForecastData('Friday', Icons.wb_sunny_outlined, '27°C', 'Sunny'),
  ];
}

class _ForecastData {
  final String day;
  final IconData icon;
  final String temp;
  final String desc;
  const _ForecastData(this.day, this.icon, this.temp, this.desc);
}

class _ForecastRow extends StatelessWidget {
  final _ForecastData data;
  const _ForecastRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              data.day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(data.icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.desc,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            data.temp,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
