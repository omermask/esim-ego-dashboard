import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/providers/users_provider.dart';
import '../../data/models/user_data.dart';
import '../../data/models/wallet_data.dart';
import '../../core/theme/app_theme_ext.dart';
import '../../core/utils/responsive_size.dart';
import '../../core/utils/translation.dart';
import '../../core/utils/toaster.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/custom_loader.dart';

class UserListWidget extends StatefulWidget {
  final VoidCallback onBack;
  const UserListWidget({super.key, required this.onBack});

  @override
  State<UserListWidget> createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  final _searchCtrl = TextEditingController();
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().load(refresh: true).then((_) {
        if (mounted) setState(() => _initialLoaded = true);
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<UsersProvider>().load(refresh: true);
  }

  void _onSearch(String q) {
    context.read<UsersProvider>().setQuery(q);
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final provider = context.watch<UsersProvider>();
    final users = provider.users;
    final loading = provider.loading;
    final hasMore = provider.hasMore;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(dc),
            _buildSearch(dc),
            Expanded(
              child: _buildList(dc, users, loading, hasMore, provider),
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
          Text(trans(context, 'All Users'),
            style: TextStyle(fontSize: rs(context, 24), fontWeight: FontWeight.w700, color: dc.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(dc) {
    return Container(
      margin: EdgeInsets.fromLTRB(rs(context, 20), rs(context, 12), rs(context, 20), 0),
      decoration: BoxDecoration(
        color: dc.iconBox,
        borderRadius: BorderRadius.circular(rs(context, 14)),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearch,
        style: TextStyle(color: dc.textPrimary, fontSize: rs(context, 14)),
        decoration: InputDecoration(
          hintText: trans(context, 'Search users...'),
          hintStyle: TextStyle(color: dc.textSecondary),
          prefixIcon: Padding(
            padding: EdgeInsets.all(rs(context, 12)),
            child: SvgPicture.asset('assets/icons/search_zoom_in_icon_242189.svg',
              width: rs(context, 20), colorFilter: ColorFilter.mode(dc.textSecondary, BlendMode.srcIn),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: rs(context, 12)),
        ),
      ),
    );
  }

  Widget _buildList(dc, List<AdminUser> users, bool loading, bool hasMore, UsersProvider provider) {
    if (!_initialLoaded && loading) return const Center(child: CustomLoader());
    if (users.isEmpty && !loading) {
      return Center(
        child: EmptyState(
          message: trans(context, 'No users found'),
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
          itemCount: users.length + (hasMore ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i >= users.length) {
              return const Padding(
                padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildUserItem(dc, users[i]);
          },
        ),
      ),
    );
  }

  Widget _buildUserItem(dc, AdminUser u) {
    return Container(
      margin: EdgeInsets.only(bottom: rs(context, 10)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: InkWell(
        onTap: () => _openDetail(u),
        borderRadius: BorderRadius.circular(rs(context, 16)),
        child: Padding(
          padding: EdgeInsets.all(rs(context, 14)),
          child: Row(
            children: [
              Container(
                width: rs(context, 48),
                height: rs(context, 48),
                decoration: BoxDecoration(
                  color: dc.iconBox,
                  borderRadius: BorderRadius.circular(rs(context, 14)),
                ),
                child: Center(
                  child: Text(
                    u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: rs(context, 20), fontWeight: FontWeight.w700, color: dc.accent),
                  ),
                ),
              ),
              SizedBox(width: rs(context, 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: rs(context, 14), color: dc.textPrimary)),
                    SizedBox(height: rs(context, 4)),
                    Text(u.phone, style: TextStyle(fontSize: rs(context, 12), color: dc.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 3)),
                    decoration: BoxDecoration(
                      color: u.isActive ? const Color(0xFF4CAF50).withValues(alpha: 0.15) : const Color(0xFFC62828).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(rs(context, 6)),
                    ),
                    child: Text(
                      u.isActive ? trans(context, 'Active') : trans(context, 'Inactive'),
                      style: TextStyle(fontSize: rs(context, 10), fontWeight: FontWeight.w600,
                        color: u.isActive ? const Color(0xFF4CAF50) : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                  SizedBox(height: rs(context, 4)),
                  Text(u.roleLabel, style: TextStyle(fontSize: rs(context, 10), color: dc.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(AdminUser u) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _UserDetailPage(user: u)),
    );
  }
}

class _UserDetailPage extends StatefulWidget {
  final AdminUser user;
  const _UserDetailPage({required this.user});

  @override
  State<_UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<_UserDetailPage> {
  late AdminUser u;

  @override
  void initState() {
    super.initState();
    u = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().loadWallet(u.id);
    });
  }

  void _toggleActive() {
    context.read<UsersProvider>().toggleActive(u.id).then((err) {
      if (mounted) {
        if (err == null) {
          context.showSuccess('User updated');
          context.read<UsersProvider>().load(refresh: true);
        } else {
          context.showError(err);
        }
      }
    });
  }

  void _ban() {
    context.read<UsersProvider>().ban(u.id).then((err) {
      if (mounted) {
        if (err == null) {
          context.showSuccess('User banned');
        } else {
          context.showError(err);
        }
      }
    });
  }

  void _unban() {
    context.read<UsersProvider>().unban(u.id).then((err) {
      if (mounted) {
        if (err == null) {
          context.showSuccess('User unbanned');
        } else {
          context.showError(err);
        }
      }
    });
  }

  void _adjustWallet() {
    final ctrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Amount (+/-)'), keyboardType: TextInputType.number),
            TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Reason')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final amount = int.tryParse(ctrl.text.trim()) ?? 0;
              if (amount == 0) return;
              final err = await context.read<UsersProvider>().adjustWallet(u.id, amount, reason: reasonCtrl.text.trim());
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (err == null) {
                  context.showSuccess('Wallet adjusted');
                } else {
                  context.showError(err);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(u.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(u.isActive ? Icons.block : Icons.check_circle, color: u.isActive ? Colors.red : Colors.green),
            onPressed: _toggleActive,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'ban') _ban();
              if (v == 'unban') _unban();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'ban', child: Text('Ban')),
              const PopupMenuItem(value: 'unban', child: Text('Unban')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(rs(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: rs(context, 80),
                    height: rs(context, 80),
                    decoration: BoxDecoration(
                      color: dc.iconBox,
                      borderRadius: BorderRadius.circular(rs(context, 20)),
                    ),
                    child: Center(
                      child: Text(
                        u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: rs(context, 36), fontWeight: FontWeight.w700, color: dc.accent),
                      ),
                    ),
                  ),
                  SizedBox(height: rs(context, 12)),
                  Text(u.name, style: TextStyle(fontSize: rs(context, 20), fontWeight: FontWeight.w700, color: dc.textPrimary)),
                  SizedBox(height: rs(context, 4)),
                  Text(u.phone, style: TextStyle(fontSize: rs(context, 14), color: dc.textSecondary)),
                ],
              ),
            ),
            SizedBox(height: rs(context, 24)),
            _infoCard(context, dc, 'Account', [
              _row(trans(context, 'Status'), u.isActive ? 'Active' : 'Inactive', context),
              _row(trans(context, 'Role'), u.roleLabel, context),
              _row(trans(context, 'Verified'), u.isVerified ? 'Yes' : 'No', context),
              _row(trans(context, 'Language'), u.language.toUpperCase(), context),
              if (u.timezone != null) _row(trans(context, 'Timezone'), u.timezone!, context),
            ]),
            SizedBox(height: rs(context, 16)),
            _infoCard(context, dc, trans(context, 'Activity'), [
              if (u.createdAt != null) _row(trans(context, 'Joined'), _formatDate(u.createdAt!), context),
              if (u.lastLoginAt != null) _row(trans(context, 'Last Login'), _formatDate(u.lastLoginAt!), context),
              _row(trans(context, 'Failed OTP'), '${u.failedOtpAttempts}', context),
            ]),
            SizedBox(height: rs(context, 16)),
            Consumer<UsersProvider>(
              builder: (ctx, up, _) {
                if (up.walletLoading) {
                  return _infoCard(context, dc, trans(context, 'Wallet'), [
                    Padding(padding: EdgeInsets.all(rs(context, 8)), child: const Center(child: CircularProgressIndicator())),
                  ]);
                }
                final w = up.wallet;
                if (w == null) return const SizedBox.shrink();
                return _infoCard(context, dc, trans(context, 'Wallet'), [
                  _row('Balance', '${w.balance} IQD', context),
                  _row('Available', '${w.availableBalance} IQD', context),
                  _row('Frozen', '${w.frozenBalance} IQD', context),
                  if (up.walletTxs.isNotEmpty) ...[
                    SizedBox(height: rs(context, 6)),
                    Text(trans(context, 'Recent Transactions'),
                      style: TextStyle(fontSize: rs(context, 12), fontWeight: FontWeight.w600, color: dc.textPrimary),
                    ),
                    ...up.walletTxs.take(3).map((tx) => Padding(
                      padding: EdgeInsets.symmetric(vertical: rs(context, 2)),
                      child: Text('${tx.type}: ${tx.amount} IQD',
                        style: TextStyle(fontSize: rs(context, 11), color: dc.textSecondary),
                      ),
                    )),
                  ],
                  SizedBox(height: rs(context, 8)),
                  InkWell(
                    onTap: _adjustWallet,
                    borderRadius: BorderRadius.circular(rs(context, 8)),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: rs(context, 6)),
                      decoration: BoxDecoration(
                        color: dc.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(rs(context, 8)),
                      ),
                      child: Center(
                        child: Text(trans(context, 'Adjust Wallet'),
                          style: TextStyle(fontSize: rs(context, 12), fontWeight: FontWeight.w600, color: dc.accent),
                        ),
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, dc, String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 14)),
      decoration: BoxDecoration(
        color: dc.bg,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs(context, 14), color: dc.textPrimary)),
          SizedBox(height: rs(context, 10)),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value, BuildContext ctx) {
    final c = ctx.dialogColors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(ctx, 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: rs(ctx, 13), color: c.textSecondary)),
          Text(value, style: TextStyle(fontSize: rs(ctx, 13), fontWeight: FontWeight.w600, color: c.textPrimary)),
        ],
      ),
    );
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return d;
    }
  }
}
