import 'package:go_router/go_router.dart';
import 'package:sc_client/features/prison_timer/presentation/pages/prison_timer_page.dart';

import '../../features/funds_disperser/presentation/pages/funds_disperser_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, __) => FundsDisperserPage.name,
    ),
    FundsDisperserPage.goRoute(title: 'Party Payouts'),
    PrisonTimerPage.goRoute(title: 'Prison Timer'),
  ],
);
