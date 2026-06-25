import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/route_model.dart';
import '../../providers/route_provider.dart';
import 'route_map_screen.dart';

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteProvider>().fetchRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Route'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<RouteProvider>(
        builder: (_, routeProvider, __) {
          if (routeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (routeProvider.routes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 60, color: AppColors.textGrey),
                  SizedBox(height: 12),
                  Text('No routes found', style: TextStyle(color: AppColors.textGrey)),
                  SizedBox(height: 4),
                  Text('Complete Mark In & Mark Out to see routes',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routeProvider.routes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _routeCard(routeProvider.routes[i]),
          );
        },
      ),
    );
  }

  Widget _routeCard(RouteModel route) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RouteMapScreen(route: route)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.route, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(route.date,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.login, size: 13, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(route.markInTime, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.logout, size: 13, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text(route.markOutTime, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                    ],
                  ),
                  if (route.distanceKm != null) ...[
                    const SizedBox(height: 4),
                    Text('${route.distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}