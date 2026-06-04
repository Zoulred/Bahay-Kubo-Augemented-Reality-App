class TutorialStep {
  final String title;
  final String description;
  final TutorialTarget target;

  TutorialStep({
    required this.title,
    required this.description,
    required this.target,
  });
}

enum TutorialTarget {
  appBar,
  carousel,
  educational,
  features,
  menu,
  profile,
