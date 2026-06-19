import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/support_provider.dart';
import '../../data/models/ticket_data.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/custom_loader.dart';

class TicketListWidget extends StatefulWidget {
  final VoidCallback onBack;
  const TicketListWidget({super.key, required this.onBack});

  @override
  State<TicketListWidget> createState() => _TicketListWidgetState();
}

class _TicketListWidgetState extends State<TicketListWidget> {
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().load(refresh: true).then((_) {
        if (mounted) setState(() => _initialLoaded = true);
      });
    });
  }

  Future<void> _refresh() async {
    await context.read<SupportProvider>().load(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<SupportProvider>();
    final tickets = provider.tickets;
    final loading = provider.loading;
    final hasMore = provider.hasMore;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            Expanded(
              child: _buildList(dc, tickets, loading, hasMore, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dc) {
    return Padding(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 16), rs(context, 20), 0),
      child: Row(
        children: [
          InkWell(
            onTap: widget.onBack,
            child: SvgPicture.asset('assets/icons/rightArrow.svg',
              width: rs(context, 22),
              colorFilter: ColorFilter.mode(dc.textPrimary, BlendMode.srcIn),
            ),
          ),
          SizedBox(width: rs(context, 12)),
          Text(trans(context, 'Support Tickets'),
            style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildList(dc, List<AdminTicket> tickets, bool loading, bool hasMore, SupportProvider provider) {
    if (!_initialLoaded && loading) return const Center(child: CustomLoader());
    if (tickets.isEmpty && !loading) {
      return Center(
        child: EmptyState(
          message: trans(context, 'No tickets found'),
          onRetry: _refresh,
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (s) {
        if (s is ScrollEndNotification && !loading && hasMore) {
          provider.load();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 8), rs(context, 20), rs(context, 100)),
          itemCount: tickets.length + (hasMore ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i >= tickets.length) {
              return const Padding(
                padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildTicketItem(dc, tickets[i]);
          },
        ),
      ),
    );
  }

  Widget _buildTicketItem(dc, AdminTicket t) {
    final priorityColor = _priorityColor(t.priority);
    final statusColor = _statusColor(t.status);

    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 10)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: InkWell(
        onTap: () => _openChat(t),
        borderRadius: BorderRadius.circular(rs(context, 16)),
        child: Padding(
          padding: EdgeInsets.all(rs(context, 14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(t.subject,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(rs(context, 6)),
                    ),
                    child: Text(t.priority[0].toUpperCase() + t.priority.substring(1),
                      style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600, color: priorityColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: rs(context, 8)),
              Row(
                children: [
                  if (t.user != null) ...[
                    Text(t.user!.name, style: TextStyle(fontSize: rs(context, 13), color: dc.textPrimary)),
                    SizedBox(width: rs(context, 8)),
                    Text(t.user!.phone, style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary)),
                  ],
                ],
              ),
              SizedBox(height: rs(context, 6)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(rs(context, 6)),
                    ),
                    child: Text(t.status[0].toUpperCase() + t.status.substring(1),
                      style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  ),
                  Text('${t.messageCount} messages', style: TextStyle(fontSize: rs(context, 11), color: dc.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'high': return const Color(0xFFE53935);
      case 'medium': return const Color(0xFFFFA000);
      case 'low': return const Color(0xFF4CAF50);
      default: return const Color(0xFF757575);
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'open': return const Color(0xFF4CAF50);
      case 'in_progress': return const Color(0xFFFFA000);
      case 'closed': return const Color(0xFF757575);
      default: return const Color(0xFF757575);
    }
  }

  void _openChat(AdminTicket t) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _TicketChatPage(ticketId: t.id, subject: t.subject)),
    );
  }
}

class _TicketChatPage extends StatefulWidget {
  final String ticketId;
  final String subject;
  const _TicketChatPage({required this.ticketId, required this.subject});

  @override
  State<_TicketChatPage> createState() => _TicketChatPageState();
}

class _TicketChatPageState extends State<_TicketChatPage> {
  final _msgCtrl = TextEditingController();
  TicketDetail? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await context.read<SupportProvider>().api.getTicket(widget.ticketId);
      if (mounted) {
        setState(() {
          _detail = TicketDetail.fromJson(d);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty) return;
    _msgCtrl.clear();
    final err = await context.read<SupportProvider>().reply(widget.ticketId, msg);
    if (mounted) {
      if (err == null) {
        _load();
      } else {
        context.showError(err);
      }
    }
  }

  Future<void> _toggleStatus() async {
    final newStatus = (_detail?.status == 'closed') ? 'open' : 'closed';
    final err = await context.read<SupportProvider>().updateStatus(widget.ticketId, newStatus);
    if (mounted) {
      if (err == null) {
        _load();
      } else {
        context.showError(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject, style: TextStyle(fontSize: rs(context, 16))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_detail != null) ...[
            IconButton(
              icon: const Icon(Icons.person_add_alt, size: 20),
              onPressed: () {
                final idCtrl = TextEditingController();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Assign Ticket'),
                    content: TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'User ID')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () async {
                          final uid = idCtrl.text.trim();
                          if (uid.isEmpty) return;
                          final err = await context.read<SupportProvider>().assign(widget.ticketId, uid);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            if (err == null) {
                              context.showSuccess('Assigned');
                              _load();
                            } else {
                              context.showError(err);
                            }
                          }
                        },
                        child: const Text('Assign'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Assign',
            ),
            IconButton(
              icon: Icon(_detail!.status == 'closed' ? Icons.lock_open : Icons.lock,
                color: _detail!.status == 'closed' ? Colors.green : Colors.grey),
              onPressed: _toggleStatus,
              tooltip: 'Toggle status',
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CustomLoader())
          : Column(
              children: [
                Expanded(
                  child: _detail!.messages.isEmpty
                      ? Center(child: EmptyState(message: 'No messages yet'))
                      : ListView.builder(
                          padding: EdgeInsets.all(rs(context, 16)),
                          itemCount: _detail!.messages.length,
                          itemBuilder: (ctx, i) {
                            final m = _detail!.messages[i];
                            final isAdmin = m.sender == 'admin';
                            return Align(
                              alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.only(bottom: rs(context, 8)),
                                padding: EdgeInsets.all(rs(context, 12)),
                                decoration: BoxDecoration(
                                  color: isAdmin ? dc.accent.withValues(alpha: 0.15) : dc.iconBox,
                                  borderRadius: BorderRadius.circular(rs(context, 14)),
                                ),
                                constraints: BoxConstraints(maxWidth: rs(context, 280)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.message, style: TextStyle(fontSize: rs(context, 13), color: dc.textPrimary)),
                                    SizedBox(height: rs(context, 4)),
                                    Text(m.senderName.isNotEmpty ? m.senderName : m.sender,
                                      style: TextStyle(fontSize: rs(context, 9), color: dc.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: EdgeInsets.all(rs(context, 12)),
                  decoration: BoxDecoration(
                    color: dc.bg,
                    border: Border(top: BorderSide(color: dc.borderColor.withValues(alpha: 0.3), width: 1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: rs(context, 14)),
                          decoration: BoxDecoration(
                            color: dc.iconBox,
                            borderRadius: BorderRadius.circular(rs(context, 14)),
                          ),
                          child: TextField(
                            controller: _msgCtrl,
                            style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 14)),
                            decoration: InputDecoration(
                              hintText: trans(context, 'Type a message...'),
                              hintStyle: TextStyle(color: dc.textSecondary),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: rs(context, 12)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: rs(context, 8)),
                      InkWell(
                        onTap: _send,
                        borderRadius: BorderRadius.circular(rs(context, 14)),
                        child: Container(
                          width: rs(context, 48),
                          height: rs(context, 48),
                          decoration: BoxDecoration(
                            color: dc.accent,
                            borderRadius: BorderRadius.circular(rs(context, 14)),
                          ),
                          child: SvgPicture.asset('assets/icons/send.svg',
                            width: rs(context, 22), colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
}
