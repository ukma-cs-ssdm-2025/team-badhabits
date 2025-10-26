import 'package:flutter/material.dart';

/// Onboarding page for Habits feature
class HabitsOnboardingPage extends StatefulWidget {
  const HabitsOnboardingPage({super.key});

  @override
  State<HabitsOnboardingPage> createState() => _HabitsOnboardingPageState();
}

class _HabitsOnboardingPageState extends State<HabitsOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    OnboardingPageData(
      title: 'Welcome to Habits',
      description: 'Build better habits by tracking what matters to you',
      icon: Icons.star,
      color: Colors.blue,
    ),
    OnboardingPageData(
      title: 'Create Your Habits',
      description: 'Define what you want to track with custom fields. '
          'Track numbers (water glasses), ratings (mood), or simple yes/no.',
      icon: Icons.add_circle,
      color: Colors.green,
    ),
    OnboardingPageData(
      title: 'Track Daily',
      description: 'Log your progress every day. The more consistent you are, '
          'the longer your streak!',
      icon: Icons.calendar_today,
      color: Colors.orange,
    ),
    OnboardingPageData(
      title: 'See Your Progress',
      description: 'View charts, statistics, and celebrate your streaks. '
          'Watch yourself improve over time!',
      icon: Icons.bar_chart,
      color: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) => _buildPage(_pages[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: () async {
                          await _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Back'),
                      )
                    else
                      const SizedBox(width: 80),
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_currentPage == _pages.length - 1) {
                          Navigator.pop(context);
                        } else {
                          await _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildPage(OnboardingPageData data) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                data.icon,
                size: 64,
                color: data.color,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              data.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              data.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

/// Onboarding page data model
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}
