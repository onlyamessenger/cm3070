import 'package:core/enums/enums.dart';
import 'package:test/test.dart';

void main() {
  group('Difficulty', () {
    test('displayName returns correct string for each value', () {
      expect(Difficulty.beginner.displayName, equals('Beginner'));
      expect(Difficulty.intermediate.displayName, equals('Intermediate'));
      expect(Difficulty.advanced.displayName, equals('Advanced'));
    });

    test('fromString round-trip for each value', () {
      for (final Difficulty value in Difficulty.values) {
        expect(Difficulty.fromString(value.name), equals(value));
      }
    });

    test('fromString is case-insensitive', () {
      expect(Difficulty.fromString('BEGINNER'), equals(Difficulty.beginner));
      expect(Difficulty.fromString('INTERMEDIATE'), equals(Difficulty.intermediate));
      expect(Difficulty.fromString('ADVANCED'), equals(Difficulty.advanced));
    });

    test('fromString throws ArgumentError for invalid input', () {
      expect(() => Difficulty.fromString('invalid'), throwsA(isA<ArgumentError>()));
    });
  });

  group('ChallengeType', () {
    test('displayName returns correct string for each value', () {
      expect(ChallengeType.quiz.displayName, equals('Quiz'));
      expect(ChallengeType.checklist.displayName, equals('Checklist'));
      expect(ChallengeType.timed.displayName, equals('Timed'));
      expect(ChallengeType.decision.displayName, equals('Decision'));
    });

    test('fromString round-trip for each value', () {
      for (final ChallengeType value in ChallengeType.values) {
        expect(ChallengeType.fromString(value.name), equals(value));
      }
    });

    test('fromString is case-insensitive', () {
      expect(ChallengeType.fromString('QUIZ'), equals(ChallengeType.quiz));
      expect(ChallengeType.fromString('CHECKLIST'), equals(ChallengeType.checklist));
      expect(ChallengeType.fromString('TIMED'), equals(ChallengeType.timed));
      expect(ChallengeType.fromString('DECISION'), equals(ChallengeType.decision));
    });

    test('fromString throws ArgumentError for invalid input', () {
      expect(() => ChallengeType.fromString('invalid'), throwsA(isA<ArgumentError>()));
    });
  });

  group('DisasterType', () {
    test('displayName returns correct string for each value', () {
      expect(DisasterType.flood.displayName, equals('Flood'));
      expect(DisasterType.bushfire.displayName, equals('Bushfire'));
      expect(DisasterType.earthquake.displayName, equals('Earthquake'));
      expect(DisasterType.cyclone.displayName, equals('Cyclone'));
      expect(DisasterType.storm.displayName, equals('Storm'));
    });

    test('fromString round-trip for each value', () {
      for (final DisasterType value in DisasterType.values) {
        expect(DisasterType.fromString(value.name), equals(value));
      }
    });

    test('fromString is case-insensitive', () {
      expect(DisasterType.fromString('FLOOD'), equals(DisasterType.flood));
      expect(DisasterType.fromString('BUSHFIRE'), equals(DisasterType.bushfire));
      expect(DisasterType.fromString('EARTHQUAKE'), equals(DisasterType.earthquake));
      expect(DisasterType.fromString('CYCLONE'), equals(DisasterType.cyclone));
      expect(DisasterType.fromString('STORM'), equals(DisasterType.storm));
    });

    test('fromString throws ArgumentError for invalid input', () {
      expect(() => DisasterType.fromString('invalid'), throwsA(isA<ArgumentError>()));
    });
  });

  group('ContentSource', () {
    test('displayName returns correct string for each value', () {
      expect(ContentSource.human.displayName, equals('Human'));
      expect(ContentSource.llm.displayName, equals('LLM'));
    });

    test('fromString round-trip for each value', () {
      for (final ContentSource value in ContentSource.values) {
        expect(ContentSource.fromString(value.name), equals(value));
      }
    });

    test('fromString is case-insensitive', () {
      expect(ContentSource.fromString('HUMAN'), equals(ContentSource.human));
      expect(ContentSource.fromString('LLM'), equals(ContentSource.llm));
    });

    test('fromString throws ArgumentError for invalid input', () {
      expect(() => ContentSource.fromString('invalid'), throwsA(isA<ArgumentError>()));
    });
  });

  group('ReadinessSectionType', () {
    test('displayName returns correct string for each value', () {
      expect(ReadinessSectionType.evacuationRoutes.displayName, equals('Evacuation Routes'));
      expect(ReadinessSectionType.emergencyContacts.displayName, equals('Emergency Contacts'));
      expect(ReadinessSectionType.emergencyKit.displayName, equals('Emergency Kit'));
      expect(ReadinessSectionType.floodRisk.displayName, equals('Flood Risk'));
      expect(ReadinessSectionType.shelterLocations.displayName, equals('Shelter Locations'));
    });

    test('fromString round-trip for each value', () {
      for (final ReadinessSectionType value in ReadinessSectionType.values) {
        expect(ReadinessSectionType.fromString(value.name), equals(value));
      }
    });

    test('fromString is case-insensitive', () {
      expect(ReadinessSectionType.fromString('EVACUATIONROUTES'), equals(ReadinessSectionType.evacuationRoutes));
      expect(ReadinessSectionType.fromString('EMERGENCYCONTACTS'), equals(ReadinessSectionType.emergencyContacts));
      expect(ReadinessSectionType.fromString('EMERGENCYKIT'), equals(ReadinessSectionType.emergencyKit));
      expect(ReadinessSectionType.fromString('FLOODRISK'), equals(ReadinessSectionType.floodRisk));
      expect(ReadinessSectionType.fromString('SHELTERLOCATIONS'), equals(ReadinessSectionType.shelterLocations));
    });

    test('fromString throws ArgumentError for invalid input', () {
      expect(() => ReadinessSectionType.fromString('invalid'), throwsA(isA<ArgumentError>()));
    });
  });

  group('ActivitySourceType', () {
    test('displayName returns correct string for each value', () {
      expect(ActivitySourceType.quest.displayName, equals('Quest'));
      expect(ActivitySourceType.challenge.displayName, equals('Challenge'));
      expect(ActivitySourceType.checkIn.displayName, equals('Check-in'));
      expect(ActivitySourceType.bonus.displayName, equals('Bonus'));
    });

    test('fromString round-trip for each value', () {
      for (final ActivitySourceType value in ActivitySourceType.values) {
        expect(ActivitySourceType.fromString(value.name), equals(value));
      }
    });

    test('fromString is case-insensitive', () {
      expect(ActivitySourceType.fromString('QUEST'), equals(ActivitySourceType.quest));
      expect(ActivitySourceType.fromString('CHALLENGE'), equals(ActivitySourceType.challenge));
      expect(ActivitySourceType.fromString('CHECKIN'), equals(ActivitySourceType.checkIn));
      expect(ActivitySourceType.fromString('BONUS'), equals(ActivitySourceType.bonus));
    });

    test('fromString throws ArgumentError for invalid input', () {
      expect(() => ActivitySourceType.fromString('invalid'), throwsA(isA<ArgumentError>()));
    });
  });

  group('PartyMemberRole', () {
    test('displayName returns correct string for each value', () {
      expect(PartyMemberRole.leader.displayName, equals('Leader'));
      expect(PartyMemberRole.member.displayName, equals('Member'));
    });

    test('fromString round-trip for each value', () {
      for (final PartyMemberRole value in PartyMemberRole.values) {
        expect(PartyMemberRole.fromString(value.name), equals(value));
      }
    });

    test('fromString is case-insensitive', () {
      expect(PartyMemberRole.fromString('LEADER'), equals(PartyMemberRole.leader));
      expect(PartyMemberRole.fromString('MEMBER'), equals(PartyMemberRole.member));
    });

    test('fromString throws ArgumentError for invalid input', () {
      expect(() => PartyMemberRole.fromString('invalid'), throwsA(isA<ArgumentError>()));
    });
  });

  group('PartyChallengeType', () {
    test('displayName returns correct string for each value', () {
      expect(PartyChallengeType.chain.displayName, equals('Chain'));
      expect(PartyChallengeType.groupXpTarget.displayName, equals('Group XP Target'));
      expect(PartyChallengeType.groupChecklist.displayName, equals('Group Checklist'));
    });

    test('fromString round-trip for each value', () {
      for (final PartyChallengeType value in PartyChallengeType.values) {
        expect(PartyChallengeType.fromString(value.name), equals(value));
      }
    });

    test('fromString is case-insensitive', () {
      expect(PartyChallengeType.fromString('CHAIN'), equals(PartyChallengeType.chain));
      expect(PartyChallengeType.fromString('GROUPXPTARGET'), equals(PartyChallengeType.groupXpTarget));
      expect(PartyChallengeType.fromString('GROUPCHECKLIST'), equals(PartyChallengeType.groupChecklist));
    });

    test('fromString throws ArgumentError for invalid input', () {
      expect(() => PartyChallengeType.fromString('invalid'), throwsA(isA<ArgumentError>()));
    });
  });
}
