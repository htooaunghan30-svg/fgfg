enum IconicProgram {
  none,
  zodiac,
  worldFestival,
}

extension IconicProgramX on IconicProgram {
  String get storageValue {
    switch (this) {
      case IconicProgram.none:
        return 'none';
      case IconicProgram.zodiac:
        return 'zodiac';
      case IconicProgram.worldFestival:
        return 'world_festival';
    }
  }

  String get title {
    switch (this) {
      case IconicProgram.none:
        return 'Standard';
      case IconicProgram.zodiac:
        return 'Zodiac Program';
      case IconicProgram.worldFestival:
        return 'World Festival Program';
    }
  }

  String get subtitle {
    switch (this) {
      case IconicProgram.none:
        return 'Use the default export overlay.';
      case IconicProgram.zodiac:
        return 'Luxury zodiac visuals after recording with an Aries prototype.';
      case IconicProgram.worldFestival:
        return 'A celebratory cinematic style reserved for a future prototype.';
    }
  }

  bool get isPremiumExport {
    switch (this) {
      case IconicProgram.none:
        return false;
      case IconicProgram.zodiac:
      case IconicProgram.worldFestival:
        return true;
    }
  }
}

IconicProgram iconicProgramFromStorage(String? value) {
  switch (value) {
    case 'zodiac':
      return IconicProgram.zodiac;
    case 'world_festival':
      return IconicProgram.worldFestival;
    default:
      return IconicProgram.none;
  }
}
