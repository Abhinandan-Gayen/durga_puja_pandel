import 'package:flutter/material.dart';

void main() => runApp(const PujoPathApp());

const _bg = Color(0xFF120606);
const _surface = Color(0xFF24100E);
const _surface2 = Color(0xFF321310);
const _red = Color(0xFFB52B1D);
const _gold = Color(0xFFF1BD28);
const _muted = Color(0xFFAE9992);
const _border = Color(0xFF4B211B);

const _pandals = [
  Pandal(
      'সুরুচি সংঘ',
      'Suruchi Sangha',
      'New Alipore',
      '2.4 km',
      '4.8',
      'Moderate',
      'Bengal Heritage',
      'https://images.unsplash.com/photo-1609947017136-9daf32a5eb16?w=900'),
  Pandal(
      'মহম্মদ আলি পার্ক',
      'Mohammad Ali Park',
      'Central Kolkata',
      '3.8 km',
      '4.6',
      'High',
      'Modern Architecture',
      'https://images.unsplash.com/photo-1567591370504-80142dc14bb0?w=900'),
  Pandal(
      'বাগবাজার সার্বজনীন',
      'Bagbazar Sarbojanin',
      'North Kolkata',
      '5.1 km',
      '4.9',
      'Low',
      'Classic Traditional',
      'https://images.unsplash.com/photo-1606298855672-3efb63017be8?w=900'),
  Pandal(
      'বালিগঞ্জ কালচারাল',
      'Ballygunge Cultural',
      'South Kolkata',
      '4.2 km',
      '4.7',
      'Moderate',
      'Artistic',
      'https://images.unsplash.com/photo-1604608672516-f1b9b1d37076?w=900'),
  Pandal(
      'দেশপ্রিয় পার্ক',
      'Deshapriya Park',
      'South Kolkata',
      '3.1 km',
      '4.5',
      'Low',
      'Eco Theme',
      'https://images.unsplash.com/photo-1603088549155-6ae9395b928f?w=900'),
  Pandal(
      'শ্রীভূমি স্পোর্টিং',
      'Sreebhumi Sporting',
      'Salt Lake',
      '6.3 km',
      '4.4',
      'High',
      'Grand Theme',
      'https://images.unsplash.com/photo-1605196560547-1fef94a8be89?w=900'),
];

class PujoPathApp extends StatelessWidget {
  const PujoPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PujoPath',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.dark(primary: _gold, secondary: _red),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final saved = <int>{0, 2};

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onExplore: () => setState(() => index = 1)),
      ExploreScreen(saved: saved, onSaved: _toggleSaved),
      const MapScreen(),
      FavouritesScreen(saved: saved, onSaved: _toggleSaved),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: IndexedStack(index: index, children: screens),
          ),
        ),
      ),
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: NavigationBar(
            height: 72,
            backgroundColor: const Color(0xFF1A0908),
            indicatorColor: _red.withValues(alpha: .25),
            selectedIndex: index,
            onDestinationSelected: (v) => setState(() => index = v),
            destinations: [
              const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home'),
              const NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: 'Explore'),
              const NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: 'Map'),
              NavigationDestination(
                icon: Badge(
                    label: Text('${saved.length}'),
                    child: const Icon(Icons.favorite_border)),
                selectedIcon: Badge(
                    label: Text('${saved.length}'),
                    child: const Icon(Icons.favorite)),
                label: 'Favourites',
              ),
              const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSaved(int value) => setState(() {
        saved.contains(value) ? saved.remove(value) : saved.add(value);
      });
}

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
            const Icon(Icons.location_on_outlined, color: _gold, size: 18),
            const Text(' Kolkata, West Bengal',
                style: TextStyle(color: _muted)),
            const Icon(Icons.keyboard_arrow_down, color: _muted),
            const Spacer(),
            _roundIcon(Icons.notifications_none),
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
                  fontSize: 28, fontWeight: FontWeight.w800, color: _gold)),
          const Text('Welcome back, Arjun 🙏',
              style: TextStyle(color: _muted, fontSize: 16)),
          const SizedBox(height: 22),
          Row(children: [
            const Expanded(child: _Search()),
            const SizedBox(width: 10),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [_red, Color(0xFFDC6C1B)]),
                  borderRadius: BorderRadius.circular(17)),
              child: const Icon(Icons.filter_alt_outlined, color: _gold),
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
          ..._pandals.take(3).map((p) => Padding(
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
          ..._pandals.take(3).map((p) => CrowdRow(p)),
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

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.saved, required this.onSaved});
  final Set<int> saved;
  final ValueChanged<int> onSaved;
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int filter = 0;
  String query = '';
  final filters = const [
    'All',
    'Nearby',
    'Award Winners',
    'Traditional',
    'Eco Theme'
  ];

  @override
  Widget build(BuildContext context) {
    final result = _pandals
        .where((p) => '${p.bn}${p.en}${p.area}'
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
    return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const Text('Explore Pandals',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
          const Text('সমস্ত প্যান্ডেল খুঁজুন', style: TextStyle(color: _gold)),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              hintText: 'Search pandal or area…',
              prefixIcon: const Icon(Icons.search, color: _gold),
              filled: true,
              fillColor: _surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: _border)),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: List.generate(
                    filters.length,
                    (i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selectedColor: _gold,
                            labelStyle: TextStyle(
                                color: filter == i ? _bg : Colors.white),
                            label: Text(filters[i]),
                            selected: filter == i,
                            onSelected: (_) => setState(() => filter = i),
                          ),
                        ))),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Text('${result.length} pandals found',
                style: const TextStyle(color: _muted)),
            const Spacer(),
            TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.tune),
                label: const Text('Sort')),
          ]),
          ...result.map((p) {
            final i = _pandals.indexOf(p);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PandalTile(
                pandal: p,
                compact: true,
                saved: widget.saved.contains(i),
                onSaved: () => widget.onSaved(i),
              ),
            );
          })
        ]);
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: CustomPaint(painter: MapPainter())),
      const Positioned(
          top: 22,
          left: 20,
          child: Text('Pandal Map · Kolkata',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
      Positioned(
          top: 62,
          left: 16,
          right: 16,
          child: Row(children: [
            _mapMode('Standard', true),
            _mapMode('Satellite', false),
            _mapMode('Crowd Heat', false),
          ])),
      const Positioned(left: 52, top: 170, child: MapPin('Bagbazar')),
      const Positioned(right: 52, top: 220, child: MapPin('Sreebhumi')),
      const Positioned(
          left: 92, top: 300, child: MapPin('Suruchi', active: true)),
      const Positioned(right: 100, top: 410, child: MapPin('Ali Park')),
      const Positioned(left: 60, top: 500, child: MapPin('Deshapriya')),
      const Positioned(right: 46, top: 530, child: MapPin('Ballygunge')),
      Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: PandalTile(pandal: _pandals.first, compact: true)),
    ]);
  }
}

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen(
      {super.key, required this.saved, required this.onSaved});
  final Set<int> saved;
  final ValueChanged<int> onSaved;
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('My Favourites',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
      const Text('আমার পছন্দের প্যান্ডেল', style: TextStyle(color: _gold)),
      const SizedBox(height: 22),
      Row(children: [
        Expanded(child: StatCard('💛', '${saved.length}', 'Saved')),
        const SizedBox(width: 10),
        Expanded(child: StatCard('🟢', '${saved.length}', 'Open Now')),
        const SizedBox(width: 10),
        Expanded(
            child: StatCard(
                '😊',
                '${saved.where((i) => _pandals[i].crowd == 'Low').length}',
                'Low Crowd')),
      ]),
      const SizedBox(height: 24),
      Row(children: [
        Text('${saved.length} pandals saved',
            style: const TextStyle(color: _gold)),
        const Spacer(),
        const Text('Sort by distance', style: TextStyle(color: _muted)),
      ]),
      const SizedBox(height: 12),
      if (saved.isEmpty)
        const Padding(
            padding: EdgeInsets.all(50),
            child: Center(child: Text('No favourites yet')))
      else
        ...saved.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PandalTile(
                  pandal: _pandals[i], saved: true, onSaved: () => onSaved(i)),
            ))
    ]);
  }
}

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
          children: [_roundIcon(Icons.settings_outlined)]),
      const CircleAvatar(
        radius: 52,
        backgroundColor: _gold,
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
          child: Text('অর্জুন চক্রবর্তী', style: TextStyle(color: _gold))),
      const Center(
          child: Text('arjun.chakraborty@gmail.com',
              style: TextStyle(color: _muted))),
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
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border)),
        child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🏆  Puja Explorer 2025',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _gold)),
              SizedBox(height: 7),
              Text('Visit 10 more pandals to unlock Gold status',
                  style: TextStyle(color: _muted)),
              SizedBox(height: 10),
              LinearProgressIndicator(
                  value: .65, color: _gold, backgroundColor: _border),
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
        secondary: const Icon(Icons.notifications_outlined, color: _gold),
        title: const Text('Notifications'),
        subtitle: const Text('বিজ্ঞপ্তি সেটিং'),
      ),
      const ProfileRow(Icons.map_outlined, 'Offline Maps', 'অফলাইন ম্যাপ',
          trailing: 'Download'),
      ListTile(
        leading: const Icon(Icons.language, color: _gold),
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
              style: TextStyle(color: _muted, fontSize: 12))),
    ]);
  }
}

class Pandal {
  const Pandal(this.bn, this.en, this.area, this.distance, this.rating,
      this.crowd, this.theme, this.image);
  final String bn, en, area, distance, rating, crowd, theme, image;
}

class PandalTile extends StatelessWidget {
  const PandalTile(
      {super.key,
      required this.pandal,
      this.compact = false,
      this.saved = false,
      this.onSaved});
  final Pandal pandal;
  final bool compact, saved;
  final VoidCallback? onSaved;
  @override
  Widget build(BuildContext context) {
    final crowdColor = pandal.crowd == 'Low'
        ? Colors.green
        : pandal.crowd == 'High'
            ? Colors.redAccent
            : _gold;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border)),
      child: compact
          ? Padding(
              padding: const EdgeInsets.all(11),
              child: Row(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(pandal.image,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        errorBuilder: _errorImage)),
                const SizedBox(width: 12),
                Expanded(
                    child: _PandalInfo(pandal: pandal, crowdColor: crowdColor)),
                IconButton(
                    onPressed: onSaved,
                    icon: Icon(saved ? Icons.favorite : Icons.favorite_border,
                        color: _gold)),
              ]),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(children: [
                Image.network(pandal.image,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: _errorImage),
                const Positioned(top: 12, left: 12, child: _OpenPill()),
                Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                        onPressed: onSaved,
                        icon: Icon(
                            saved ? Icons.favorite : Icons.favorite_border),
                        style: IconButton.styleFrom(backgroundColor: _red))),
                Positioned(
                    bottom: 10,
                    left: 12,
                    child: Text('⭐ ${pandal.rating}',
                        style: const TextStyle(
                            color: _gold, fontWeight: FontWeight.bold))),
                Positioned(bottom: 10, right: 12, child: Text(pandal.distance)),
              ]),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PandalInfo(pandal: pandal, crowdColor: crowdColor),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                          value: pandal.crowd == 'High'
                              ? .85
                              : pandal.crowd == 'Low'
                                  ? .25
                                  : .58,
                          color: crowdColor,
                          backgroundColor: _border),
                      const SizedBox(height: 12),
                      SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.navigation_outlined),
                              label: const Text('Navigate'))),
                    ]),
              )
            ]),
    );
  }
}

class _PandalInfo extends StatelessWidget {
  const _PandalInfo({required this.pandal, required this.crowdColor});
  final Pandal pandal;
  final Color crowdColor;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(pandal.bn,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('${pandal.area} · ${pandal.distance}',
            style: const TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 7),
        Wrap(spacing: 8, children: [
          Text('⭐ ${pandal.rating}',
              style: const TextStyle(color: _gold, fontSize: 12)),
          Text(pandal.crowd,
              style: TextStyle(
                  color: crowdColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const Text('● Open',
              style: TextStyle(color: Colors.green, fontSize: 12)),
        ])
      ]);
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

class _Search extends StatelessWidget {
  const _Search();
  @override
  Widget build(BuildContext context) => TextField(
        decoration: InputDecoration(
          hintText: 'প্যান্ডেল, এলাকা বা থিম খুঁজুন',
          prefixIcon: const Icon(Icons.search, color: _gold),
          suffixIcon: const Icon(Icons.mic_none, color: _gold),
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: _border)),
        ),
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
                style: const TextStyle(color: _muted, fontSize: 12)),
        ])),
        Text(trailing,
            style: TextStyle(
                color: trailing == 'LIVE' ? Colors.redAccent : _gold,
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
                color: selected ? _red : _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? _gold : _border)),
            child: Text(emoji, style: const TextStyle(fontSize: 27)),
          ),
          const SizedBox(height: 7),
          Text(label,
              style: TextStyle(color: selected ? _gold : _muted, fontSize: 12)),
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
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('$count pandals',
              style: const TextStyle(color: _muted, fontSize: 12))
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
            color: _surface, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(pandal.bn,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    'Wait: ~${pandal.crowd == 'High' ? 40 : pandal.crowd == 'Low' ? 5 : 15} min · Best: 7:00 AM',
                    style: const TextStyle(color: _muted, fontSize: 11))
              ])),
          Text(pandal.crowd, style: const TextStyle(color: _gold)),
        ]),
      );
}

class EventRow extends StatelessWidget {
  const EventRow(this.icon, this.name, this.bn, this.time, {super.key});
  final String icon, name, bn, time;
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: _surface2, child: Text(icon)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$bn · $time', style: const TextStyle(color: _muted)),
      );
}

class StatCard extends StatelessWidget {
  const StatCard(this.icon, this.value, this.label, {super.key});
  final String icon, value, label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _border)),
        child: Column(children: [
          Text(icon),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: _gold)),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 10))
        ]),
      );
}

class ProfileRow extends StatelessWidget {
  const ProfileRow(this.icon, this.title, this.subtitle,
      {super.key, this.trailing = '›'});
  final IconData icon;
  final String title, subtitle, trailing;
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: _gold),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(trailing, style: const TextStyle(color: _gold)),
      );
}

class MapPin extends StatelessWidget {
  const MapPin(this.label, {super.key, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          width: active ? 48 : 38,
          height: active ? 48 : 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? _gold : _red,
              boxShadow: [
                if (active)
                  BoxShadow(
                      color: _gold.withValues(alpha: .35),
                      blurRadius: 24,
                      spreadRadius: 15)
              ]),
          child: const Text('🛕'),
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: _bg, borderRadius: BorderRadius.circular(7)),
            child:
                Text(label, style: const TextStyle(color: _gold, fontSize: 9))),
      ]);
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF1A0909));
    final grid = Paint()
      ..color = _border.withValues(alpha: .42)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 44) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final road = Paint()
      ..color = const Color(0xFF67451A)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    final p = Path()
      ..moveTo(0, size.height * .42)
      ..cubicTo(size.width * .3, size.height * .34, size.width * .55,
          size.height * .52, size.width, size.height * .4);
    canvas.drawPath(p, road);
    canvas.drawLine(Offset(size.width * .33, 0),
        Offset(size.width * .32, size.height), road);
    canvas.drawLine(Offset(size.width * .7, 0),
        Offset(size.width * .65, size.height), road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _roundIcon(IconData icon) => Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
          color: _surface,
          shape: BoxShape.circle,
          border: Border.all(color: _border)),
      child: Icon(icon, color: _gold),
    );

Widget _mapMode(String text, bool active) => Padding(
      padding: const EdgeInsets.only(right: 7),
      child: Chip(
          backgroundColor: active ? _gold : _surface,
          label:
              Text(text, style: TextStyle(color: active ? _bg : Colors.white))),
    );

Widget _errorImage(BuildContext context, Object error, StackTrace? stack) =>
    Container(
        color: _surface2,
        alignment: Alignment.center,
        child: const Text('🛕', style: TextStyle(fontSize: 38)));

class _OpenPill extends StatelessWidget {
  const _OpenPill();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: const Color(0xCC073E21),
            borderRadius: BorderRadius.circular(20)),
        child: const Text('● Open',
            style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
      );
}
