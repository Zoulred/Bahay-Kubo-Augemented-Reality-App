import 'package:flutter/material.dart';

enum Rarity { common, uncommon, rare, epic, legendary }

class Vegetable {
  final String id;
  final String name;
  final String englishName;
  final String imagePath;
  final Rarity rarity;
  final Color color;
  final String scientificName;
  final String varieties;
  final String nutritionalFacts;
  final String healthBenefits;
  final String commonRecipes;
  final String growingTips;
  final String description;

  Vegetable({
    required this.id,
    required this.name,
    required this.englishName,
    required this.imagePath,
    required this.rarity,
    required this.color,
    required this.scientificName,
    required this.varieties,
    required this.nutritionalFacts,
    required this.healthBenefits,
    required this.commonRecipes,
    required this.growingTips,
    required this.description,
  });
}

class ARVegetable {
  final Vegetable vegetable;
  final String id;
  double latitude;
  double longitude;
  double distance;
  double bearing;

  ARVegetable({
    required this.vegetable,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.bearing,
  });
}
