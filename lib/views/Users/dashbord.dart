
import 'package:durga_puja_pandel/core/theme/normal_color.dart';
import 'package:durga_puja_pandel/core/utils/globa_data.dart';
import 'package:durga_puja_pandel/views/widgets/pandel.dart';
import 'package:durga_puja_pandel/views/widgets/roundIcon.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        sliver: SliverList.list(children: [
          Row(children: [
            const Icon(Icons.location_on_outlined, color: gold, size: 18),
            const Text(' Kolkata, West Bengal',
                style: TextStyle(color: muted)),
            const Icon(Icons.keyboard_arrow_down, color: muted),
            const Spacer(),
            roundIcon(Icons.notifications_none),
            const SizedBox(width: 10),
            const CircleAvatar(
              radius: 23,
              backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=160'),
            )
          ]),
          const SizedBox(height: 12),
          const Text('শুভ দুর্গাপূজা',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, color: gold)),
          const Text('Welcome back, Arjun 🙏',
              style: TextStyle(color: muted, fontSize: 16)),
          const SizedBox(height: 22),
          Row(children: [
            const Expanded(child: _Search()),
            const SizedBox(width: 10),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [red, Color(0xFFDC6C1B)]),
                  borderRadius: BorderRadius.circular(17)),
              child: const Icon(Icons.filter_alt_outlined, color: gold),
            )
          ]),
          const SizedBox(height: 24),
          _Hero(onPressed: onExplore),
          const SizedBox(height: 26),
          const SectionTitle('Categories'),
          const SizedBox(height: 14),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              Category('📍', 'Nearby', true),
              Category('⭐', 'Famous', false),
              Category('🎨', 'Theme', false),
              Category('🪔', 'Traditional', false),
              Category('🏆', 'Award', false),
              Category('👨‍👩‍👧', 'Family', false),
            ]),
          ),
          const SizedBox(height: 28),
          const SectionTitle('Trending Pandals',
              subtitle: 'আজ সবচেয়ে বেশি দেখা হচ্ছে'),
          const SizedBox(height: 14),
          ...pandals.take(3).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PandalTile(pandal: p),
              )),
          const SizedBox(height: 12),
          const SectionTitle('Popular Areas'),
          const SizedBox(height: 14),
          const Wrap(spacing: 10, runSpacing: 10, children: [
            AreaChip('Salt Lake', '38'),
            AreaChip('New Town', '24'),
            AreaChip('Behala', '31'),
            AreaChip('North Kolkata', '56'),
            AreaChip('South Kolkata', '44'),
            AreaChip('Dum Dum', '19'),
          ]),
          const SizedBox(height: 28),
          const SectionTitle('Live Crowd Updates', trailing: 'LIVE'),
          const SizedBox(height: 12),
          ...pandals.take(3).map((p) => CrowdRow(p)),
          const SizedBox(height: 28),
          const SectionTitle('Upcoming Events', subtitle: 'আসন্ন অনুষ্ঠান'),
          const SizedBox(height: 12),
          const EventRow('🪔', 'Sandhi Puja', 'সন্ধিপূজা', 'Oct 11 · 11:48 PM'),
          const EventRow(
              '🔥', 'Dhunuchi Dance', 'ধুনুচি নাচ', 'Oct 12 · 8:00 PM'),
          const EventRow('🎶', 'Cultural Program', 'সাংস্কৃতিক অনুষ্ঠান',
              'Oct 13 · 6:00 PM'),
        ]),
      )
    ]);
  }
}


class _Search extends StatelessWidget {
  const _Search();
  @override
  Widget build(BuildContext context) => TextField(
        decoration: InputDecoration(
          hintText: 'প্যান্ডেল, এলাকা বা থিম খুঁজুন',
          prefixIcon: const Icon(Icons.search, color: gold),
          suffixIcon: const Icon(Icons.mic_none, color: gold),
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: border)),
        ),
      );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Container(
        height: 245,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: const DecorationImage(
              image: NetworkImage(
                  'https://images.unsplash.com/photo-1604608672516-f1b9b1d37076?w=1200'),
              fit: BoxFit.cover,
              colorFilter:
                  ColorFilter.mode(Color(0x55000000), BlendMode.darken)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Chip(label: Text('🎉 PUJA 2025')),
          const Spacer(),
          const Text('Explore the Best\nPandals Near You',
              style: TextStyle(
                  fontSize: 27,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif')),
          const Text('এই পুজোয় ঘুরে দেখুন সেরা প্যান্ডেল',
              style: TextStyle(color: Color(0xFFFFD79B))),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: onPressed, child: const Text('Explore Now  ›')),
        ]),
      );
}


class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title,
      {super.key, this.subtitle, this.trailing = 'See all'});
  final String title, trailing;
  final String? subtitle;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          if (subtitle != null)
            Text(subtitle!,
                style: const TextStyle(color: muted, fontSize: 12)),
        ])),
        Text(trailing,
            style: TextStyle(
                color: trailing == 'LIVE' ? Colors.redAccent : gold,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ]);
}

class Category extends StatelessWidget {
  const Category(this.emoji, this.label, this.selected, {super.key});
  final String emoji, label;
  final bool selected;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(children: [
          Container(
            width: 72,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: selected ? red : surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? gold : border)),
            child: Text(emoji, style: const TextStyle(fontSize: 27)),
          ),
          const SizedBox(height: 7),
          Text(label,
              style: TextStyle(color: selected ? gold : muted, fontSize: 12)),
        ]),
      );
}

class AreaChip extends StatelessWidget {
  const AreaChip(this.name, this.count, {super.key});
  final String name, count;
  @override
  Widget build(BuildContext context) => Container(
        width: 148,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('$count pandals',
              style: const TextStyle(color: muted, fontSize: 12))
        ]),
      );
}

class CrowdRow extends StatelessWidget {
  const CrowdRow(this.pandal, {super.key});
  final Pandal pandal;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: surface, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(pandal.bn,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    'Wait: ~${pandal.crowd == 'High' ? 40 : pandal.crowd == 'Low' ? 5 : 15} min · Best: 7:00 AM',
                    style: const TextStyle(color: muted, fontSize: 11))
              ])),
          Text(pandal.crowd, style: const TextStyle(color: gold)),
        ]),
      );
}

class EventRow extends StatelessWidget {
  const EventRow(this.icon, this.name, this.bn, this.time, {super.key});
  final String icon, name, bn, time;
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: surface2, child: Text(icon)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$bn · $time', style: const TextStyle(color: muted)),
      );
}