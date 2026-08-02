import 'package:durga_puja_pandel/core/theme/normal_color.dart';
import 'package:durga_puja_pandel/core/utils/globa_data.dart';
import 'package:durga_puja_pandel/views/widgets/pandel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  Widget build(BuildContext context) {
    final result = pandals
        .where(
          (p) => '${p.bn}${p.en}${p.area}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE50914),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        centerTitle: true,
        title: const Text(
          'Explore Pandals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFE50914),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: [
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              hintText: 'Search pandal or area…',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: border),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: Row(
          //     children: List.generate(
          //       filters.length,
          //       (i) => Padding(
          //         padding: const EdgeInsets.only(right: 8),
          //         child: ChoiceChip(
          //           selectedColor: gold,
          //           labelStyle: TextStyle(color: bg),
          //           label: Text(filters[i]),
          //           selected: filter == i,
          //           onSelected: (_) => setState(() => filter = i),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 18),
          Row(
            children: [
              Text('${result.length} pandals found'),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.tune),
                label: const Text('Sort'),
              ),
            ],
          ),
          ...result.map((p) {
            final i = pandals.indexOf(p);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PandalTile(
                pandal: p,
                compact: true,
                saved: widget.saved.contains(i),
                onSaved: () => widget.onSaved(i),
              ),
            );
          }),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
