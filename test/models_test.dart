import 'package:flutter_test/flutter_test.dart';
import 'package:trouvez_binome/features/auth/models/user_model.dart';
import 'package:trouvez_binome/features/profile/models/skill_model.dart';
import 'package:trouvez_binome/features/profile/models/profile_model.dart';
import 'package:trouvez_binome/features/matching/models/match_model.dart';
import 'package:trouvez_binome/features/messaging/models/message_model.dart';
import 'package:trouvez_binome/features/notifications/models/notification_model.dart';

void main() {
  // Tests UserModel 
  group('UserModel', () {
    test('fromMap() crée un UserModel correct', () {
      final map = {
        'name': 'Luce',
        'email': 'luce@email.com',
        'filiere': 'Informatique',
        'annee': 'L3',
        'bio': 'Développeuse Flutter',
        'github': 'github.com/luce',
        'linkedin': 'linkedin.com/luce',
        'profileCompletion': 0.8,
        'createdAt': '2026-05-25T13:15:00.000',
      };

      final user = UserModel.fromMap(map, 'user123');

      expect(user.id, 'user123');
      expect(user.name, 'Luce');
      expect(user.email, 'luce@email.com');
      expect(user.filiere, 'Informatique');
      expect(user.profileCompletion, 0.8);
    });

    test('toMap() retourne les bonnes clés', () {
      final user = UserModel(
        id: 'user123',
        name: 'Luce',
        email: 'luce@email.com',
        filiere: 'Informatique',
        annee: 'L3',
        createdAt: DateTime(2026, 5, 25),
      );

      final map = user.toMap();

      expect(map['name'], 'Luce');
      expect(map['email'], 'luce@email.com');
      expect(map.containsKey('id'), false); // id ne doit pas être dans la map
    });
  });

  // Tests SkillModel
  group('SkillModel', () {
    test('fromMap() crée un SkillModel correct', () {
      final map = {
        'name': 'Flutter',
        'category': 'Framework',
        'isPreset': true,
      };

      final skill = SkillModel.fromMap(map, 'skill123');

      expect(skill.id, 'skill123');
      expect(skill.name, 'Flutter');
      expect(skill.category, 'Framework');
      expect(skill.isPreset, true);
    });

    test('toMap() retourne les bonnes valeurs', () {
      final skill = SkillModel(
        id: 'skill123',
        name: 'Flutter',
        category: 'Framework',
      );

      final map = skill.toMap();

      expect(map['name'], 'Flutter');
      expect(map['isPreset'], true);
    });
  });

  // Tests ProfileModel
  group('ProfileModel', () {
    test('fromMap() gère les listes et maps imbriquées', () {
      final map = {
        'skills': ['skill1', 'skill2'],
        'availability': {
          'Lundi': ['08h-10h', '10h-12h'],
          'Mardi': ['14h-16h'],
        },
        'updatedAt': '2026-05-25T13:15:00.000',
      };

      final profile = ProfileModel.fromMap(map, 'user123');

      expect(profile.skillIds.length, 2);
      expect(profile.skillIds[0], 'skill1');
      expect(profile.availability['Lundi']?.length, 2);
    });

    test('fromMap() gère les valeurs nulles', () {
      final map = {
        'updatedAt': '2026-05-25T13:15:00.000',
      };

      final profile = ProfileModel.fromMap(map, 'user123');

      expect(profile.skillIds, isEmpty);
      expect(profile.availability, isEmpty);
    });
  });

  // Tests MatchModel
  group('MatchModel', () {
    test('fromMap() convertit le status correctement', () {
      final map = {
        'user1Id': 'user1',
        'user2Id': 'user2',
        'score': 0.85,
        'status': 'accepted',
        'createdAt': '2026-05-25T13:15:00.000',
      };

      final match = MatchModel.fromMap(map, 'match123');

      expect(match.status, MatchStatus.accepted);
      expect(match.score, 0.85);
    });

    test('status par défaut est pending', () {
      final map = {
        'user1Id': 'user1',
        'user2Id': 'user2',
        'score': 0.5,
        'status': 'statut_inconnu',
        'createdAt': '2026-05-25T13:15:00.000',
      };

      final match = MatchModel.fromMap(map, 'match123');

      expect(match.status, MatchStatus.pending);
    });
  });

  // Tests MessageModel
  group('MessageModel', () {
    test('fromMap() crée un MessageModel correct', () {
      final map = {
        'senderId': 'user1',
        'content': 'Salut, tu veux être mon binôme ?',
        'timestamp': '2026-05-25T13:15:00.000',
        'isRead': false,
      };

      final message = MessageModel.fromMap(map, 'msg123');

      expect(message.senderId, 'user1');
      expect(message.content, 'Salut, tu veux être mon binôme ?');
      expect(message.isRead, false);
    });
  });

  // Tests NotificationModel
  group('NotificationModel', () {
    test('fromMap() convertit le type correctement', () {
      final map = {
        'type': 'newMatch',
        'message': 'Tu as un nouveau binôme suggéré !',
        'isRead': false,
        'createdAt': '2026-05-25T13:15:00.000',
      };

      final notif = NotificationModel.fromMap(map, 'notif123');

      expect(notif.type, NotificationType.newMatch);
      expect(notif.isRead, false);
    });
  });
}