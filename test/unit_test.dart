import 'package:flutter_test/flutter_test.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/tree/data/models/tree_model.dart';

void main() {
  group('toTitleCase spacing and formatting tests', () {
    test('properly formats Bachelor\'s Degree with space', () {
      expect("Bachelor's Degree".toTitleCase, equals("Bachelor's Degree"));
      expect("bachelor's degree".toTitleCase, equals("Bachelor's Degree"));
      expect("Bachelor'sDegree".toTitleCase, equals("Bachelor's Degree"));
      expect("Master's Degree".toTitleCase, equals("Master's Degree"));
      expect("Master'sDegree".toTitleCase, equals("Master's Degree"));
      expect("High School".toTitleCase, equals("High School"));
      expect("female".toTitleCase, equals("Female"));
      expect("full-time".toTitleCase, equals("Full-Time"));
      expect("bachelor_degree".toTitleCase, equals("Bachelor Degree"));
    });
  });

  group('AnnouncementModel bannerUrls tests', () {
    test('parses bannerUrls array correctly', () {
      final json = {
        '_id': '123',
        'title': 'Test Announcement',
        'bannerUrls': ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
      };
      final model = AnnouncementModel.fromJson(json);
      expect(model.bannerUrls, equals(['https://example.com/1.jpg', 'https://example.com/2.jpg']));
      expect(model.bannerUrl, equals('https://example.com/1.jpg'));
      expect(model.allBannerUrls.length, equals(2));
    });

    test('backward compatible with single bannerUrl', () {
      final json = {
        '_id': '123',
        'title': 'Old Announcement',
        'bannerUrl': 'https://example.com/single.jpg',
      };
      final model = AnnouncementModel.fromJson(json);
      expect(model.bannerUrl, equals('https://example.com/single.jpg'));
      expect(model.allBannerUrls, equals(['https://example.com/single.jpg']));
    });
  });

  group('LinkedUser tree data and profile tests', () {
    test('parses new fields returned by backend', () {
      final json = {
        '_id': 'u123',
        'name': 'John Doe',
        'linkedinLink': 'https://linkedin.com/in/johndoe',
        'phone': '+123456789',
        'dateOfBirth': '1995-05-15',
        'gender': 'Male',
        'education': "Bachelor's Degree",
        'universityName': 'MIT',
        'fieldOfWork': 'Software Engineering',
      };
      final linked = LinkedUser.fromJson(json);
      expect(linked.linkedinLink, equals('https://linkedin.com/in/johndoe'));
      expect(linked.phone, equals('+123456789'));
      expect(linked.dateOfBirth, equals('1995-05-15'));
      expect(linked.gender, equals('Male'));
      expect(linked.education, equals("Bachelor's Degree"));
      expect(linked.universityName, equals('MIT'));
      expect(linked.fieldOfWork, equals('Software Engineering'));

      final userModel = linked.toUserModel();
      expect(userModel.resolvedLinkedIn, equals('https://linkedin.com/in/johndoe'));
      expect(userModel.phone, equals('+123456789'));
      expect(userModel.education, equals("Bachelor's Degree"));
    });
  });

  group('SuperAdmin exclusion tests', () {
    test('identifies superAdmin accurately', () {
      final u1 = UserModel(role: 'superAdmin');
      final u2 = UserModel(role: 'superadmin');
      final u3 = UserModel(role: 'super_admin');
      final u4 = UserModel(role: 'admin');
      final u5 = UserModel(role: 'user');

      bool isSuperAdmin(UserModel u) {
        final r = (u.role ?? '').trim().toLowerCase();
        return r == 'superadmin' || r == 'super_admin';
      }

      expect(isSuperAdmin(u1), isTrue);
      expect(isSuperAdmin(u2), isTrue);
      expect(isSuperAdmin(u3), isTrue);
      expect(isSuperAdmin(u4), isFalse);
      expect(isSuperAdmin(u5), isFalse);
    });
  });
}
