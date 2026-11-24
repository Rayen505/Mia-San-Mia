// Drawing of the stadium map. The photo is public/img/stadium/stadium-map.jpg (1024 x 798 pixels).
// The names, prices and pitch photos of the stands come from the database (table stands),
// here we only keep the SHAPES, they are matched with the stands by their code.

export const MAP_WIDTH = 1024
export const MAP_HEIGHT = 798

export const standShapes = {
  // top of the photo: the main stand ("Mia san mia")
  west: {
    points: '180,140 240,95 784,95 844,140 704,260 320,260',
    radar: 'M26 14 Q50 8 74 14 L68 22 Q50 18 32 22 Z',
  },
  // bottom of the photo
  ost: {
    points: '320,538 704,538 844,658 784,703 240,703 180,658',
    radar: 'M26 66 Q50 72 74 66 L68 58 Q50 62 32 58 Z',
  },
  // left of the photo
  nord: {
    points: '180,140 320,260 290,399 320,538 180,658 85,538 70,399 85,260',
    radar: 'M14 24 Q8 40 14 56 L24 50 Q20 40 24 30 Z',
  },
  // right of the photo (Bayern crest)
  sued: {
    points: '844,140 704,260 734,399 704,538 844,658 939,538 954,399 939,260',
    radar: 'M86 24 Q92 40 86 56 L76 50 Q80 40 76 30 Z',
  },
}
