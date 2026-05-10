import 'package:flutter/material.dart';

/// OnboardingSlide — Immutable data for a single onboarding screen.
/// Keeps UI data separate from layout code.
class OnboardingSlide {
  const OnboardingSlide({
    required this.headline,
    required this.headlineAccent,
    required this.body,
    required this.accentColor,
    required this.iconData,
    required this.features,
    required this.ctaLabel,
    this.tagline,
  });

  final String headline;
  final String headlineAccent; // Renders in brand orange
  final String body;
  final Color accentColor;
  final IconData iconData;
  final List<OnboardingFeature> features;
  final String ctaLabel;
  final String? tagline;
}

class OnboardingFeature {
  const OnboardingFeature({
    required this.icon,
    required this.label,
  });
  final IconData icon;
  final String label;
}

/// Slide definitions — brand-aligned emotional progression.
const List<OnboardingSlide> kOnboardingSlides = [
  OnboardingSlide(
    headline: 'Real Burgers.',
    headlineAccent: 'Real Fast.',
    body: 'Farm-fresh ingredients. Made to order.\nDelivered while it\'s still sizzling.',
    accentColor: Color(0xFFE8560A),
    iconData: Icons.lunch_dining_rounded,
    ctaLabel: 'Next',
    features: [
      OnboardingFeature(icon: Icons.eco_rounded, label: 'Farm Fresh'),
      OnboardingFeature(icon: Icons.timer_rounded, label: '18 Min Avg'),
      OnboardingFeature(icon: Icons.local_shipping_rounded, label: 'Free ₹199+'),
    ],
  ),
  OnboardingSlide(
    headline: 'Your Cravings,',
    headlineAccent: 'Your Way.',
    body: 'Customise every burger to your taste.\nNo compromises. No pre-set combos.',
    accentColor: Color(0xFFE8560A),
    iconData: Icons.tune_rounded,
    ctaLabel: 'Next',
    tagline: 'Built for burger lovers',
    features: [
      OnboardingFeature(icon: Icons.check_circle_rounded, label: 'Custom Build'),
      OnboardingFeature(icon: Icons.no_food_rounded, label: 'Allergen Safe'),
      OnboardingFeature(icon: Icons.favorite_rounded, label: 'Save Favourites'),
    ],
  ),
  OnboardingSlide(
    headline: 'Earn With',
    headlineAccent: 'Every Bite.',
    body: 'Every order earns you Farm Points.\nRedeem for free meals and exclusive drops.',
    accentColor: Color(0xFFE8560A),
    iconData: Icons.stars_rounded,
    ctaLabel: 'Grab Your Meal',
    tagline: 'The tastiest rewards programme',
    features: [
      OnboardingFeature(icon: Icons.stars_rounded, label: 'Farm Points'),
      OnboardingFeature(icon: Icons.card_giftcard_rounded, label: 'Free Meals'),
      OnboardingFeature(icon: Icons.bolt_rounded, label: 'Flash Drops'),
    ],
  ),
];
