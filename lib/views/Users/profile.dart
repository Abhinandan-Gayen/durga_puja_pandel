
import 'package:durga_puja_pandel/core/theme/normal_color.dart';
import 'package:durga_puja_pandel/views/widgets/roundIcon.dart';
import 'package:durga_puja_pandel/views/widgets/satrtcard.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notifications = true;
  bool english = true;
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [roundIcon(Icons.settings_outlined)]),
      const CircleAvatar(
        radius: 52,
        backgroundColor: gold,
        child: CircleAvatar(
            radius: 49,
            backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200')),
      ),
      const SizedBox(height: 12),
      const Center(
          child: Text('Arjun Chakraborty',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
      const Center(
          child: Text('অর্জুন চক্রবর্তী', style: TextStyle(color: gold))),
      const Center(
          child: Text('arjun.chakraborty@gmail.com',
              style: TextStyle(color: muted))),
      const SizedBox(height: 8),
      const Center(child: Chip(label: Text('🏅 Puja Explorer · Since 2023'))),
      const SizedBox(height: 20),
      const Row(children: [
        Expanded(child: StatCard('🛕', '47', 'Pandals Visited')),
        SizedBox(width: 8),
        Expanded(child: StatCard('💛', '2', 'Favourites')),
        SizedBox(width: 8),
        Expanded(child: StatCard('⭐', '12', 'Reviews Given')),
      ]),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border)),
        child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🏆  Puja Explorer 2025',
                  style: TextStyle(fontWeight: FontWeight.bold, color: gold)),
              SizedBox(height: 7),
              Text('Visit 10 more pandals to unlock Gold status',
                  style: TextStyle(color: muted)),
              SizedBox(height: 10),
              LinearProgressIndicator(
                  value: .65, color: gold, backgroundColor: border),
              SizedBox(height: 5),
              Align(alignment: Alignment.centerRight, child: Text('65%')),
            ]),
      ),
      const SizedBox(height: 18),
      const ProfileRow(Icons.calendar_month, 'My Visits', 'পরিদর্শন ইতিহাস',
          trailing: '12 pandals'),
      SwitchListTile(
        value: notifications,
        onChanged: (v) => setState(() => notifications = v),
        secondary: const Icon(Icons.notifications_outlined, color: gold),
        title: const Text('Notifications'),
        subtitle: const Text('বিজ্ঞপ্তি সেটিং'),
      ),
      const ProfileRow(Icons.map_outlined, 'Offline Maps', 'অফলাইন ম্যাপ',
          trailing: 'Download'),
      ListTile(
        leading: const Icon(Icons.language, color: gold),
        title: const Text('Language'),
        subtitle: const Text('ভাষা'),
        trailing: SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('EN')),
            ButtonSegment(value: false, label: Text('BN'))
          ],
          selected: {english},
          onSelectionChanged: (v) => setState(() => english = v.first),
        ),
      ),
      const ProfileRow(Icons.lock_outline, 'Privacy', 'গোপনীয়তা'),
      const ProfileRow(Icons.chat_bubble_outline, 'Help & Support', 'সাহায্য'),
      const ProfileRow(Icons.star_outline, 'Rate PujoPath', 'অ্যাপ রেট করুন'),
      const ProfileRow(
          Icons.share_outlined, 'Share App', 'বন্ধুদের সাথে শেয়ার'),
      const SizedBox(height: 18),
      OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out')),
      const SizedBox(height: 16),
      const Center(
          child: Text('PujoPath v2.5.0 · Made with ❤️ in Kolkata',
              style: TextStyle(color: muted, fontSize: 12))),
    ]);
  }
}

class ProfileRow extends StatelessWidget {
  const ProfileRow(this.icon, this.title, this.subtitle,
      {super.key, this.trailing = '›'});
  final IconData icon;
  final String title, subtitle, trailing;
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: gold),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(trailing, style: const TextStyle(color: gold)),
      );
}




