import 'dart:async';
import 'package:flutter/material.dart';

import '../services/codehub_state.dart';

class ChatMessage {
  final String id;
  final String senderName;
  final String senderHandle;
  final String senderAvatarUrl;
  final String senderRole;
  final bool isMe;
  final String content;
  final String? codeBlock;
  final DateTime timestamp;
  final String p2pDeliveryTag;
  int reactionsCount;
  bool isReacted;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderHandle,
    required this.senderAvatarUrl,
    required this.senderRole,
    required this.isMe,
    required this.content,
    this.codeBlock,
    required this.timestamp,
    this.p2pDeliveryTag = 'Gossipsub Delivered',
    this.reactionsCount = 0,
    this.isReacted = false,
  });
}

class ChatChannel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int unreadCount;
  final bool isDirectMessage;

  const ChatChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.unreadCount = 0,
    this.isDirectMessage = false,
  });
}

class LiveChatScreen extends StatefulWidget {
  final CodeHubState state;

  const LiveChatScreen({super.key, required this.state});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  ChatChannel _selectedChannel = const ChatChannel(
    id: 'chan-1',
    name: '#general-swarm',
    description: 'Global peer discussions, swarm status & announcements',
    icon: Icons.tag,
    unreadCount: 3,
  );

  final List<ChatChannel> _channels = const [
    ChatChannel(
      id: 'chan-1',
      name: '#general-swarm',
      description: 'Global peer discussions, swarm status & announcements',
      icon: Icons.tag,
      unreadCount: 3,
    ),
    ChatChannel(
      id: 'chan-2',
      name: '#dev-team',
      description: 'Core Rust & Flutter engineering collaboration',
      icon: Icons.code,
      unreadCount: 0,
    ),
    ChatChannel(
      id: 'chan-3',
      name: '#p2p-sync',
      description: 'Kademlia DHT, Noise TLS & blockstore delta replication',
      icon: Icons.sync_alt,
      unreadCount: 1,
    ),
    ChatChannel(
      id: 'chan-4',
      name: '#repo-discussions',
      description: 'Repository feedback, commit DAG reviews & code specs',
      icon: Icons.forum_outlined,
      unreadCount: 0,
    ),
  ];

  final List<ChatChannel> _directMessages = const [
    ChatChannel(
      id: 'dm-1',
      name: 'SanFranciscoPeer (Device A)',
      description: 'Online • 24ms ping • 12.8 GB seeded',
      icon: Icons.circle,
      isDirectMessage: true,
    ),
    ChatChannel(
      id: 'dm-2',
      name: 'TokyoNode (Device B)',
      description: 'Online • 142ms ping • 48.2 GB seeded',
      icon: Icons.circle,
      isDirectMessage: true,
    ),
    ChatChannel(
      id: 'dm-3',
      name: 'BerlinSeed (Device C)',
      description: 'Online • High-Capacity Seed Node',
      icon: Icons.circle,
      isDirectMessage: true,
    ),
    ChatChannel(
      id: 'dm-4',
      name: 'ControlRelayServer',
      description: 'Active Relay • Auth & Metadata Coordinator',
      icon: Icons.dns,
      isDirectMessage: true,
    ),
  ];

  late Map<String, List<ChatMessage>> _channelMessages;
  bool _isPeerTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChatHistory();
  }

  void _initializeChatHistory() {
    _channelMessages = {
      'chan-1': [
        ChatMessage(
          id: 'm1',
          senderName: 'GranthikSom',
          senderHandle: '@granthik',
          senderAvatarUrl: 'G',
          senderRole: 'ADMIN',
          isMe: false,
          content: 'Welcome to the CodeHub Swarm Live Chat! All messages are broadcasted via libp2p Gossipsub pub/sub channel.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 24)),
          reactionsCount: 5,
        ),
        ChatMessage(
          id: 'm2',
          senderName: 'SanFranciscoPeer',
          senderHandle: '@sf_peer',
          senderAvatarUrl: 'SF',
          senderRole: 'SEEDER',
          isMe: false,
          content: 'Just finished replicating codehub-core-p2p to Node #42! 380 Git Blobs (42.1 MB) synchronized with 100% integrity.',
          codeBlock: 'libp2p::gossipsub::Topic::new("codehub/swarm/v1/general")',
          timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
          reactionsCount: 3,
        ),
        ChatMessage(
          id: 'm3',
          senderName: 'TokyoNode',
          senderHandle: '@tokyo_node',
          senderAvatarUrl: 'TN',
          senderRole: 'PEER',
          isMe: false,
          content: 'Rabin fingerprint chunking speed boosted to 450 MB/s on the Rust engine build.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          reactionsCount: 2,
        ),
        ChatMessage(
          id: 'm4',
          senderName: 'GranthikSom (You)',
          senderHandle: '@soham',
          senderAvatarUrl: 'S',
          senderRole: 'OWNER',
          isMe: true,
          content: 'Awesome progress! I am currently testing the Live Chat sidebar interface and real-time mesh messaging.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
          reactionsCount: 4,
          isReacted: true,
        ),
      ],
      'chan-2': [
        ChatMessage(
          id: 'm5',
          senderName: 'GranthikSom',
          senderHandle: '@granthik',
          senderAvatarUrl: 'G',
          senderRole: 'ADMIN',
          isMe: false,
          content: 'Please verify the Argon2id zero-plain-password identity verification endpoint before shipping v1.4.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
      'chan-3': [
        ChatMessage(
          id: 'm6',
          senderName: 'ControlRelayServer',
          senderHandle: '@relay',
          senderAvatarUrl: 'CR',
          senderRole: 'RELAY',
          isMe: false,
          content: 'Kademlia DHT routing table resynchronized. 14 active swarm peers connected via Noise TLS transport.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
      ],
    };
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderName: 'GranthikSom (You)',
      senderHandle: '@soham',
      senderAvatarUrl: 'S',
      senderRole: 'OWNER',
      isMe: true,
      content: text,
      timestamp: DateTime.now(),
      p2pDeliveryTag: 'Gossipsub Broadcast Sent',
    );

    setState(() {
      final currentList = _channelMessages[_selectedChannel.id] ?? [];
      currentList.add(newMessage);
      _channelMessages[_selectedChannel.id] = currentList;
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate real-time peer reply after 1.5 seconds
    setState(() {
      _isPeerTyping = true;
    });

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isPeerTyping = false;
        final peerReply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderName: _selectedChannel.isDirectMessage ? _selectedChannel.name : 'SanFranciscoPeer',
          senderHandle: '@sf_peer',
          senderAvatarUrl: 'SF',
          senderRole: 'SEEDER',
          isMe: false,
          content: 'Received message over Gossipsub! Hash: sha256_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}.',
          timestamp: DateTime.now(),
          p2pDeliveryTag: 'Verified & Replicated',
        );
        final currentList = _channelMessages[_selectedChannel.id] ?? [];
        currentList.add(peerReply);
        _channelMessages[_selectedChannel.id] = currentList;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final currentMessages = _channelMessages[_selectedChannel.id] ?? [];

    return Row(
      children: [
        // Left Channel & Peer Selector Panel (Sidebar within Chat)
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.grey.shade100,
            border: Border(
              right: BorderSide(
                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.forum, color: Colors.blueAccent, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Swarm Live Chat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Filter channels or peers...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 16),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0D1117) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),

              // Navigation Categories
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Swarm Channels Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'SWARM CHANNELS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    ..._channels.map((chan) => _buildChannelItem(chan, isDark)),

                    const SizedBox(height: 16),

                    // Direct Messages Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ONLINE PEERS (DMs)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.circle, color: Color(0xFF3FB950), size: 6),
                                SizedBox(width: 4),
                                Text(
                                  '4 Online',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3FB950)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._directMessages.map((dm) => _buildChannelItem(dm, isDark)),
                  ],
                ),
              ),

              // Swarm Status Bar in Sidebar Bottom
              Container(
                padding: const EdgeInsets.all(12),
                color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade200,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3FB950),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF3FB950), blurRadius: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gossipsub Pub/Sub',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Noise TLS • 14 Peers',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Main Chat Content View
        Expanded(
          child: Column(
            children: [
              // Top Chat Header Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedChannel.icon,
                          color: Colors.blueAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _selectedChannel.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'P2P Broadcast',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purpleAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _selectedChannel.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Tooltip(
                          message: 'Encrypted Noise TLS Stream',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F81F7).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF2F81F7)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.shield, color: Color(0xFF38BDF8), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Noise TLS Encrypted',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.cleaning_services_outlined, size: 20),
                          tooltip: 'Clear Chat History',
                          onPressed: () {
                            setState(() {
                              _channelMessages[_selectedChannel.id] = [];
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chat Messages Feed
              Expanded(
                child: Container(
                  color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
                  child: currentMessages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: isDark ? const Color(0xFF30363D) : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No messages in ${_selectedChannel.name} yet.',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Send a message to start the Gossipsub broadcast!',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF484F58) : Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(24),
                          itemCount: currentMessages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageCard(currentMessages[index], isDark);
                          },
                        ),
                ),
              ),

              // Peer Typing Indicator
              if (_isPeerTyping)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  color: isDark ? const Color(0xFF161B22) : Colors.grey.shade200,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Swarm peer is typing over Gossipsub...',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Bottom Input Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.code, color: Colors.blueAccent),
                      tooltip: 'Insert Code Block',
                      onPressed: () {
                        _messageController.text += '\n```rust\n// Code snippet\n```\n';
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF8B949E)),
                      tooltip: 'Attach Git Object Link',
                      onPressed: () {
                        _messageController.text += ' commit_e4b0c2a1 ';
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Message ${_selectedChannel.name} (Markdown & code snippets supported)...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF8B949E) : Colors.grey,
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF30363D) : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F81F7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Send', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChannelItem(ChatChannel channel, bool isDark) {
    final isSelected = _selectedChannel.id == channel.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _selectedChannel = channel;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF21262D) : Colors.blueAccent.withValues(alpha: 0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.blueAccent.withValues(alpha: 0.4))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                channel.icon,
                size: 16,
                color: channel.isDirectMessage
                    ? const Color(0xFF3FB950)
                    : (isSelected ? Colors.blueAccent : (isDark ? const Color(0xFF8B949E) : Colors.grey.shade700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  channel.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.blueAccent)
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (channel.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${channel.unreadCount}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(ChatMessage message, bool isDark) {
    final roleColor = message.senderRole == 'ADMIN'
        ? const Color(0xFFA371F7)
        : (message.senderRole == 'OWNER'
            ? const Color(0xFF38BDF8)
            : const Color(0xFF3FB950));

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: message.isMe
                    ? [const Color(0xFF2F81F7), const Color(0xFF8957E5)]
                    : [const Color(0xFF238636), const Color(0xFF2F81F7)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              message.senderAvatarUrl,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(width: 14),

          // Content Box
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        message.senderRole,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatTimestamp(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF8B949E) : Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        message.p2pDeliveryTag,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: isDark ? const Color(0xFF38BDF8) : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Message Text Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? const Color(0xFF2F81F7).withValues(alpha: 0.12)
                        : (isDark ? const Color(0xFF161B22) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: message.isMe
                          ? const Color(0xFF2F81F7).withValues(alpha: 0.4)
                          : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        message.content,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),

                      // Code Block snippet preview
                      if (message.codeBlock != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF040D14),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF30363D)),
                          ),
                          child: Text(
                            message.codeBlock!,
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 12,
                              color: Color(0xFF7EE787),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Reaction Button
                InkWell(
                  onTap: () {
                    setState(() {
                      message.isReacted = !message.isReacted;
                      message.reactionsCount += message.isReacted ? 1 : -1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: message.isReacted
                          ? const Color(0xFF2F81F7).withValues(alpha: 0.2)
                          : (isDark ? const Color(0xFF21262D) : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: message.isReacted
                            ? const Color(0xFF2F81F7)
                            : (isDark ? const Color(0xFF30363D) : Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👍', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${message.reactionsCount}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: message.isReacted
                                ? const Color(0xFF2F81F7)
                                : (isDark ? const Color(0xFF8B949E) : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
