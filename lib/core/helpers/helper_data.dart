
class HelperData {




  /// fake data
  static final List<Map<String, dynamic>> announcements = [
    {
      'title': 'Annual Company Meetup 2025',
      'description':
      'Join us for our annual company meetup where we celebrate achievements, share updates, and connect with teammates from across all departments.',
      'imageUrl': null,
      'status': 'In progress',
    },
    {
      'title': 'New Office Policy Update',
      'description':
      'Important updates regarding the new office attendance and remote work policy effective from next month. Please read carefully and acknowledge.',
      'imageUrl':
      'https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg',
      'status': 'Upcoming',
    },
    {
      'title': 'System Maintenance Notice',
      'description':
      'Scheduled system maintenance will occur this Saturday from 12:00 AM to 4:00 AM. All services will be temporarily unavailable during this window.',
      'imageUrl': null,
      'status': 'Upcoming',
    },
    {
      'title': 'Holiday Schedule 2025',
      'description':
      'Please find the updated list of public holidays and office closures for the remainder of 2025. Plan your leaves accordingly.',
      'imageUrl':
      'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg',
      'status': 'Completed',
    },
  ];




  static final List<Map<String, dynamic>> member = [
    {
      'title': 'Abdullah Al Mamun',
      'description':
      'Badar',
      'imageUrl': '',
      'select': false,
    },

  ];




  static List<Map<String, dynamic>> messages = [
    {
      'text': 'Hey, how are you?',
      'isMe': true,
      'time': DateTime.now().subtract(Duration(minutes: 5)),
      'status': 'seen',
    },
    {
      'text': 'I am good, thanks! What about you?',
      'isMe': false,
      'time': DateTime.now().subtract(Duration(minutes: 3)),
      'status': 'seen',
    },
    {
      'text': 'I am doing great, working on a new project.',
      'isMe': true,
      'time': DateTime.now().subtract(Duration(minutes: 1)),
      'status': 'seen',
    },
    {
      'text': 'That sounds interesting!',
      'isMe': false,
      'time': DateTime.now(),
      'status': 'delivered',
    },
  ];


  static final List<Map<String, dynamic>> demoFamilyList = [
    {
      "name": "Mohammad",
      "level": 0,
      "children": [
        {
          "name": "Lulouah",
          "level": 1,
          "children": [
            {
              "name": "Ali",
              "level": 2,
              "children": []
            },
            {
              "name": "Sara",
              "level": 2,
              "children": []
            }
          ]
        },
        {
          "name": "Ibrahim",
          "level": 1,
          "children": [
            {
              "name": "Omar",
              "level": 2,
              "children": []
            },
            {
              "name": "Aisha",
              "level": 2,
              "children": []
            },
            {
              "name": "Yusuf",
              "level": 2,
              "children": []
            }
          ]
        },
        {
          "name": "Nassir",
          "level": 1,
          "children": [
            {
              "name": "Montasir Mihad",
              "level": 2,
              "children": []
            }
          ]
        }
      ]
    }
  ];


}
