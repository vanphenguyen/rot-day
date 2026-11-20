/// What is being poured.
///
/// Each drink plays differently: foam keeps rising after the stream stops,
/// and a thick drink keeps falling for longer once you let go. The order
/// here is also the order they are unlocked in endless mode.
enum Drink {
  tea(
    foamPerHeight: 0,
    settleRate: 1.5,
    thickness: 0.85,
    highestLine: 0.9,
    color: 0xFF8B4A1F,
    foamColor: 0xFFD9B79B,
    emoji: '🍵',
    unlockAt: 0,
  ),
  coffee(
    foamPerHeight: 0.08,
    settleRate: 2,
    thickness: 1.1,
    highestLine: 0.88,
    color: 0xFFC2855A,
    foamColor: 0xFFEBD4BC,
    emoji: '☕',
    unlockAt: 2,
  ),
  sugarcane(
    foamPerHeight: 0.2,
    settleRate: 1.6,
    thickness: 1,
    highestLine: 0.84,
    color: 0xFFB9CF4A,
    foamColor: 0xFFE8F0B8,
    emoji: '🥤',
    unlockAt: 4,
  ),
  smoothie(
    foamPerHeight: 0.26,
    settleRate: 1.3,
    thickness: 1.6,
    highestLine: 0.82,
    color: 0xFFE86A8C,
    foamColor: 0xFFFBD5DF,
    emoji: '🍓',
    unlockAt: 6,
  ),
  soda(
    foamPerHeight: 0.35,
    settleRate: 2.6,
    thickness: 0.85,
    highestLine: 0.8,
    color: 0xFFF2612C,
    foamColor: 0xFFFFD9C2,
    emoji: '🥫',
    unlockAt: 8,
  ),

  /// Milk tea with a thick cream top. Takes the last place, and the same
  /// numbers, that beer had before release, so daily glasses are unchanged.
  milkTea(
    foamPerHeight: 0.45,
    settleRate: 1.3,
    thickness: 1,
    highestLine: 0.76,
    color: 0xFFC8956B,
    foamColor: 0xFFFFF4E0,
    emoji: '🧋',
    unlockAt: 10,
  );

  const Drink({
    required this.foamPerHeight,
    required this.settleRate,
    required this.thickness,
    required this.highestLine,
    required this.color,
    required this.foamColor,
    required this.emoji,
    required this.unlockAt,
  });

  /// Foam made for each unit of height the liquid climbs.
  final double foamPerHeight;

  /// Share of the foam that settles each second.
  final double settleRate;

  /// How long the stream keeps falling after you let go, as a multiplier.
  /// A smoothie trails far more than iced tea.
  final double thickness;

  /// The highest the line is ever put for this drink. Foamy drinks need
  /// room above the line, or they would spill every time.
  final double highestLine;

  /// ARGB colour of the liquid, and of its foam.
  final int color;
  final int foamColor;

  final String emoji;

  /// Glasses filled in endless mode before this drink turns up.
  final int unlockAt;

  bool get hasFoam => foamPerHeight > 0;

  /// The drinks on offer after [glasses] filled in one endless run.
  static List<Drink> unlockedAfter(int glasses) => [
    for (final d in values)
      if (d.unlockAt <= glasses) d,
  ];
}
