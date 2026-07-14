/// The 4 skin types this quiz can resolve to. Kept as an enum (not a raw
/// string) so scoring logic can't accidentally typo a skin type name.
enum SkinType { oily, dry, combination, sensitive }

extension SkinTypeDisplay on SkinType {
  String get label {
    switch (this) {
      case SkinType.oily:
        return 'Oily';
      case SkinType.dry:
        return 'Dry';
      case SkinType.combination:
        return 'Combination';
      case SkinType.sensitive:
        return 'Sensitive';
    }
  }

  String get description {
    switch (this) {
      case SkinType.oily:
        return 'Your skin tends to look shiny and produces excess sebum, '
            'especially through the day. Breakouts and enlarged pores are common.';
      case SkinType.dry:
        return 'Your skin often feels tight, flaky, or rough, and may lack '
            'natural moisture — especially in colder weather.';
      case SkinType.combination:
        return 'You get oiliness in your T-zone (forehead, nose, chin) while '
            'your cheeks stay normal to dry.';
      case SkinType.sensitive:
        return 'Your skin reacts easily to new products, weather changes, '
            'or fragrances — redness and irritation show up quickly.';
    }
  }

  /// Maps to a `concern` value that already exists in the product catalog,
  /// so quiz results can reuse the same Product Listing filter that Home's
  /// skin-concern grid already uses — no new filtering logic needed.
  String get matchingConcern {
    switch (this) {
      case SkinType.oily:
        return 'Acne & Blemishes';
      case SkinType.dry:
        return 'Dry & Flaky Skin';
      case SkinType.combination:
        return 'Dark Spots';
      case SkinType.sensitive:
        return 'Anti-Aging';
    }
  }

  String get routineTip {
    switch (this) {
      case SkinType.oily:
        return 'Look for oil-free, non-comedogenic formulas and a gentle '
            'foaming cleanser morning and night.';
      case SkinType.dry:
        return 'Prioritize a rich moisturizer and a hydrating, non-foaming '
            'cleanser to avoid stripping natural oils.';
      case SkinType.combination:
        return 'Balance is key — a lightweight gel moisturizer works well, '
            'with extra care in the T-zone.';
      case SkinType.sensitive:
        return 'Choose fragrance-free, minimal-ingredient products and '
            'patch-test anything new for a few days first.';
    }
  }
}

class QuizOption {
  final String text;
  final SkinType skinType;

  const QuizOption({required this.text, required this.skinType});
}

class QuizQuestion {
  final String question;
  final List<QuizOption> options;

  const QuizQuestion({required this.question, required this.options});
}

/// Static question bank — no API needed, this is purely client-side logic.
class QuizData {
  static const List<QuizQuestion> questions = [
    QuizQuestion(
      question: 'How does your skin feel a few hours after washing your face?',
      options: [
        QuizOption(
          text: 'Shiny and greasy, especially on the forehead and nose',
          skinType: SkinType.oily,
        ),
        QuizOption(text: 'Tight, rough, or flaky', skinType: SkinType.dry),
        QuizOption(
          text: 'Oily in the T-zone, normal or dry on the cheeks',
          skinType: SkinType.combination,
        ),
        QuizOption(
          text: 'Fine, but sometimes reactive or itchy',
          skinType: SkinType.sensitive,
        ),
      ],
    ),
    QuizQuestion(
      question: 'How often do you deal with breakouts or clogged pores?',
      options: [
        QuizOption(
          text: 'Frequently, all over my face',
          skinType: SkinType.oily,
        ),
        QuizOption(
          text: 'Rarely — my skin is more prone to dryness than breakouts',
          skinType: SkinType.dry,
        ),
        QuizOption(
          text: 'Mostly around my nose and chin',
          skinType: SkinType.combination,
        ),
        QuizOption(
          text: 'Occasionally, and it comes with redness or irritation',
          skinType: SkinType.sensitive,
        ),
      ],
    ),
    QuizQuestion(
      question: 'How does your skin react to new skincare products?',
      options: [
        QuizOption(
          text: 'Usually fine, though it can get oilier',
          skinType: SkinType.oily,
        ),
        QuizOption(
          text: 'It often feels even drier at first',
          skinType: SkinType.dry,
        ),
        QuizOption(
          text: 'Depends on the area — T-zone vs. cheeks react differently',
          skinType: SkinType.combination,
        ),
        QuizOption(
          text: 'Redness, itching, or stinging happens easily',
          skinType: SkinType.sensitive,
        ),
      ],
    ),
    QuizQuestion(
      question: 'How would you describe your pores?',
      options: [
        QuizOption(
          text: 'Visibly large, especially in the center of my face',
          skinType: SkinType.oily,
        ),
        QuizOption(text: 'Small and barely noticeable', skinType: SkinType.dry),
        QuizOption(
          text: 'Larger in the T-zone, smaller elsewhere',
          skinType: SkinType.combination,
        ),
        QuizOption(
          text: 'Normal-sized, but my skin looks blotchy at times',
          skinType: SkinType.sensitive,
        ),
      ],
    ),
    QuizQuestion(
      question: 'By the end of the day, your skin mostly feels...',
      options: [
        QuizOption(text: 'Slick and shiny all over', skinType: SkinType.oily),
        QuizOption(
          text: 'Dry and in need of moisturizer',
          skinType: SkinType.dry,
        ),
        QuizOption(
          text: 'Shiny in the middle, comfortable at the edges',
          skinType: SkinType.combination,
        ),
        QuizOption(
          text: 'Fine, unless something irritated it earlier',
          skinType: SkinType.sensitive,
        ),
      ],
    ),
  ];
}
