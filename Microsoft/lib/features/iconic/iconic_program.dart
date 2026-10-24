enum IconicProgram {
  none,
  zodiac,
  worldFestival,
  professionHobby,
  luxuryStudio,
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
      case IconicProgram.professionHobby:
        return 'profession_hobby';
      case IconicProgram.luxuryStudio:
        return 'luxury_overlay_studio';
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
      case IconicProgram.professionHobby:
        return 'Profession / Hobby Theme Program';
      case IconicProgram.luxuryStudio:
        return 'Luxury Overlay Studio Program';
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
      case IconicProgram.professionHobby:
        return 'Profession grade UI packs with dedicated rep and accuracy systems.';
      case IconicProgram.luxuryStudio:
        return 'Your fully customizable luxury overlay program with editable premium visuals.';
    }
  }

  bool get isPremiumExport {
    switch (this) {
      case IconicProgram.none:
        return false;
      case IconicProgram.zodiac:
      case IconicProgram.worldFestival:
      case IconicProgram.professionHobby:
      case IconicProgram.luxuryStudio:
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
    case 'profession_hobby':
      return IconicProgram.professionHobby;
    case 'luxury_overlay_studio':
      return IconicProgram.luxuryStudio;
    default:
      return IconicProgram.none;
  }
}
