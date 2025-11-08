import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
         BackgroundDecoration(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25, // half of your 50x50 container
                                backgroundImage: AssetImage(
                                  'assets/images/Jins_Black.jpg', // replace with your image URL
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello!',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Pathrose Jinz',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.black87,
                                  size: 24,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Task Card
                    Container(
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // color: Color.fromARGB(255, 235, 235, 235),
                          color: const Color(0xFFB24BF3).withOpacity(0.1),

                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top Purple Section
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF6C3FE4),
                                    Color(0xFF6C3FE4),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(22),
                                  topRight: Radius.circular(22),
                                  bottomLeft: Radius.circular(22),
                                  bottomRight: Radius.circular(22),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your today\'s task\nalmost done !!',
                                        style: AppTextStyle.base.copyWith(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(
                                            0xFF7B2CBF,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'Continue Ride',
                                          style: AppTextStyle.base.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF6C3FE4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 80), // Progress Circle
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: CircularProgressIndicator(
                                            value: 0.85,
                                            strokeWidth: 5,
                                            backgroundColor: Colors.white
                                                .withOpacity(0.3),
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Colors.white),
                                          ),
                                        ),
                                        Text(
                                          '85%',
                                          style: AppTextStyle.base.copyWith(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bottom White Section
                            Container(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                bottom: 24,
                                top: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFB24BF3),
                                          Color(0xFF9D4EDD),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Current Campaign Details',
                                      style: AppTextStyle.base.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Kalyan Hypermarket',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.purple.shade300,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '13 Aug 2025 - 13 Sep 2025',
                                        style: AppTextStyle.base.copyWith(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.directions_car,
                                        size: 15,
                                        color: Colors.purple.shade300,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '3,500 kms',
                                        style: AppTextStyle.base.copyWith(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Current Campaign Details Button

                    // Participants Header
                    Row(
                      children: [
                        Text(
                          'Participants',
                          style: AppTextStyle.base.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '9',
                            style: AppTextStyle.base.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Participant List
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          _buildParticipantTile(
                            rank: 1,
                            name: 'Rahul Kannan',
                            distance: '90 kms',
                            percentage: 90,
                            color: const Color(0xFFEC4899),
                            image:
                                'assets/images/WhatsApp Image 2025-10-09 at 15.56.15_75758adb.jpg',
                          ),
                          _buildParticipantTile(
                            rank: 2,
                            name: 'Hari',
                            distance: '80 kms',
                            percentage: 80,
                            color: const Color.fromARGB(255, 4, 128, 10),
                            image:
                                'assets/images/WhatsApp Image 2025-10-09 at 15.50.26_c3f943b4.jpg',
                          ),
                          _buildParticipantTile(
                            rank: 3,
                            name: 'Thomson',
                            distance: '78 kms',
                            percentage: 78,
                            color: const Color.fromARGB(255, 82, 32, 124),
                            image:
                                'assets/images/WhatsApp Image 2025-10-09 at 15.49.29_f02dc3ba.jpg',
                          ),
                          _buildParticipantTile(
                            rank: 4,
                            name: 'Shahi',
                            distance: '60 kms',
                            percentage: 60,
                            color: const Color.fromARGB(255, 63, 47, 14),
                            image:
                                'assets/images/WhatsApp Image 2025-10-14 at 12.05.33_667e6003.jpg',
                          ),
                          _buildParticipantTile(
                            rank: 5,
                            name: 'Hiran',
                            distance: '50 kms',
                            percentage: 50,
                            color: const Color.fromARGB(255, 155, 0, 0),
                            image:
                                'assets/images/WhatsApp Image 2025-10-11 at 12.51.37_5d6912de.jpg',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile({
    required int rank,
    required String name,
    required String distance,
    required int percentage,
    required Color color,
    required String image,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '$rank',
                style: AppTextStyle.base.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Rank',
                style: AppTextStyle.base.copyWith(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(radius: 22, backgroundImage: AssetImage(image)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyle.base.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  distance,
                  style: AppTextStyle.base.copyWith(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: AppTextStyle.base.copyWith(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
