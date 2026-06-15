import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:masic_generation/features/banner/data/models/banner_model.dart';
import 'package:masic_generation/features/poll/data/models/poll_model.dart';

class HomeModel {
  final List<AnnouncementModel> announcements;
  final List<PollModel> polls;
  final List<BannerModel>? banner;


  HomeModel( {required this.announcements , required this.polls, required this.banner});
}