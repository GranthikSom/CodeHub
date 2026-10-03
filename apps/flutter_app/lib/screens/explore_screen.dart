import 'package:flutter/material.dart';
import '../services/codehub_state.dart';
import '../widgets/repo_card.dart';
import '../widgets/create_repository_dialog.dart';

class ExploreScreen extends StatefulWidget {
  final CodeHubState state;

  const ExploreScreen({super.key, required this.state});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'Trending';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allDisplay = widget.state.repositories;
    final filtered = allDisplay.where((r) {
      if (_selectedCategory == 'Rust' &&
          !(r.language?.toLowerCase().contains('rust') ?? false) &&
          !r.tags.contains('rust')) {
        return false;
      }
      if (_selectedCategory == 'Flutter' &&
          !(r.language?.toLowerCase().contains('dart') ?? false) &&
          !r.tags.contains('flutter')) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        return r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.owner.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Search Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore P2P Swarm Catalog',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover and pin decentralized Git repositories hosted across peer devices.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                width: 300,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Filter explore catalog...',
                    hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, size: 18, color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 8),
                  ),
                ),
              ),
            ],
          ),
          // Live Architecture Event Toast Banner
          if (widget.state.latestLiveEventMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F6FEB), Color(0xFF238636)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.amber, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.state.latestLiveEventMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                    onPressed: () => widget.state.dismissLiveEventMessage(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Pipeline Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(Icons.hub_outlined, color: Color(0xFF58A6FF), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Real-Time Swarm Pipeline:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'User A → CodeHub API → PostgreSQL → Redis Event Bus → WebSocket → Live Explore Page',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.state.backendStatus == 'online'
                          ? (isDark ? const Color(0xFF3FB950) : const Color(0xFF238636))
                          : widget.state.backendStatus == 'connecting'
                              ? const Color(0xFFD29922)
                              : const Color(0xFFCF222E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.state.backendStatus == 'online'
                          ? const Color(0xFF3FB950)
                          : widget.state.backendStatus == 'connecting'
                              ? const Color(0xFFD29922)
                              : const Color(0xFFCF222E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.state.backendStatus == 'online'
                        ? 'Connected'
                        : widget.state.backendStatus == 'connecting'
                            ? 'Connecting...'
                            : 'Offline',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.state.backendStatus == 'online'
                          ? const Color(0xFF3FB950)
                          : widget.state.backendStatus == 'connecting'
                              ? const Color(0xFFD29922)
                              : const Color(0xFFCF222E),
                    ),
                  ),
                  if (widget.state.backendStatus != 'online') ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => widget.state.reconnectBackend(),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF21262D),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF30363D)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.refresh, size: 12, color: Colors.white70),
                            SizedBox(width: 4),
                            Text('Retry', style: TextStyle(fontSize: 11, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),


          // Category Filters
          Row(
            children: ['Trending', 'Most Seeded', 'Recently Updated', 'Rust', 'Flutter']
                .map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                        selectedColor: Colors.blueAccent.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: _selectedCategory == cat
                              ? Colors.blueAccent
                              : (isDark ? const Color(0xFF8B949E) : Colors.grey.shade700),
                          fontWeight: _selectedCategory == cat ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // Catalog List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.travel_explore_rounded,
                            size: 56,
                            color: isDark ? const Color(0xFF30363D) : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No repositories matching "$_searchQuery"'
                                : 'No public repositories indexed in swarm yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first repository to announce and replicate content chunks across peer nodes.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => CreateRepositoryDialog(state: widget.state),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF238636),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('New Repository', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return RepoCard(repo: filtered[index], state: widget.state);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
