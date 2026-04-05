class AiScenario {
  final String id;
  final String emoji;
  final String label;
  final String? scenarioText;

  const AiScenario({
    required this.id,
    required this.emoji,
    required this.label,
    this.scenarioText,
  });

  bool get isCustom => id == 'custom';
}

const kAiScenarios = [
  AiScenario(id: 'coffee_shop',       emoji: '☕', label: 'Coffee shop',       scenarioText: 'Two strangers strike up a conversation while waiting in line at a busy coffee shop.'),
  AiScenario(id: 'airport_reunion',   emoji: '✈️', label: 'Airport reunion',   scenarioText: 'Two old friends unexpectedly run into each other at an airport departure gate.'),
  AiScenario(id: 'grocery_store',     emoji: '🛒', label: 'Grocery store',     scenarioText: 'Two neighbours chat while shopping at the supermarket and discover they are hosting the same kind of dinner party.'),
  AiScenario(id: 'doctor_visit',      emoji: '🏥', label: 'Doctor visit',      scenarioText: 'A patient nervously asks a doctor about their test results and next steps.'),
  AiScenario(id: 'job_interview',     emoji: '💼', label: 'Job interview',     scenarioText: 'A candidate is being interviewed for their dream job and has to answer tough questions.'),
  AiScenario(id: 'new_neighbour',     emoji: '🏠', label: 'New neighbour',     scenarioText: 'Someone just moved in next door and introduces themselves to their neighbour for the first time.'),
  AiScenario(id: 'tech_support',      emoji: '📱', label: 'Tech support',      scenarioText: 'A frustrated customer calls tech support because their phone keeps restarting unexpectedly.'),
  AiScenario(id: 'birthday_surprise', emoji: '🎂', label: 'Birthday surprise', scenarioText: 'Friends are secretly planning a surprise birthday party and trying to keep it from the birthday person.'),
  AiScenario(id: 'gym_tips',          emoji: '🏋️', label: 'Gym tips',          scenarioText: 'A gym veteran gives unsolicited — but actually helpful — workout advice to a newcomer.'),
  AiScenario(id: 'weather_smalltalk', emoji: '🌧️', label: 'Weather small talk',scenarioText: 'Two colleagues are stuck waiting for rain to stop outside their office and make small talk.'),
  AiScenario(id: 'restaurant_order',  emoji: '🍕', label: 'Restaurant order',  scenarioText: 'Two friends argue lightheartedly about what to order at a pizza restaurant.'),
  AiScenario(id: 'book_rec',          emoji: '📚', label: 'Book recommendation',scenarioText: 'An avid reader tries to convince a sceptical friend to read a book they loved.'),
  AiScenario(id: 'bus_delay',         emoji: '🚌', label: 'Bus delay',         scenarioText: 'Two commuters bond over a very delayed bus and share their daily frustrations.'),
  AiScenario(id: 'movie_debate',      emoji: '🎬', label: 'Movie debate',      scenarioText: 'Two friends passionately disagree about whether a sequel was better than the original.'),
  AiScenario(id: 'custom',            emoji: '✏️', label: 'Custom…'),
];
