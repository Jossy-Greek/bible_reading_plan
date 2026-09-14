/// Short public-domain (KJV) verses shown as a quiet accent. The app has no
/// Bible text yet; these are the only Scripture it displays.
const List<({String text, String ref})> kVerses = [
  (text: 'Be still, and know that I am God.', ref: 'Psalm 46:10'),
  (
    text: 'Thy word is a lamp unto my feet, and a light unto my path.',
    ref: 'Psalm 119:105',
  ),
  (
    text:
        'The grass withereth, the flower fadeth: but the word of our God shall stand for ever.',
    ref: 'Isaiah 40:8',
  ),
  (text: 'Let the word of Christ dwell in you richly.', ref: 'Colossians 3:16'),
  (
    text: 'Blessed are they that hear the word of God, and keep it.',
    ref: 'Luke 11:28',
  ),
  (
    text:
        'Open thou mine eyes, that I may behold wondrous things out of thy law.',
    ref: 'Psalm 119:18',
  ),
  (
    text:
        'Man shall not live by bread alone, but by every word that proceedeth out of the mouth of God.',
    ref: 'Matthew 4:4',
  ),
];

({String text, String ref}) verseFor(int index) =>
    kVerses[index % kVerses.length];
