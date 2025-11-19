
class OnboardingData {
  final String title;
  final String description;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  static List<OnboardingData> getOnboardingData() {
    return [
      OnboardingData(
        title: "Welcome to Casa Rancha",
        description: "Welcome to the app everyone’s whispering about... but no one admits they use. 🔥 Confess. React. Stay anonymous. You're safe here.",
        imagePath: "assets/images/firstAvater.png",
      ),
      OnboardingData(
        title: "Level Up with Ghost Mode",
        description: "Get honesty, unlock new levels, Ghost posts in real-time, choose music as you rise.",
        imagePath: "assets/images/secondAvater.png",
      ),
      OnboardingData(
        title: "Your Secrets. Their Reactions",
        description: "Say it. Own it. Hide your identity, not your truth. Ghost posts inspire honest conversations and reactions from people who get it.",
        imagePath: "assets/images/thirdAvater.png",
      ),
    ];
  }
}