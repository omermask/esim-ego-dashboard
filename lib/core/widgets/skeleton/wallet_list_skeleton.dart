import 'package:flutter/material.dart';
import '../../utils/responsive_size.dart';

class WalletListSkeleton extends StatefulWidget {
  const WalletListSkeleton({super.key});

  @override
  State<WalletListSkeleton> createState() => _WalletListSkeletonState();
}

class _WalletListSkeletonState extends State<WalletListSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: EdgeInsets.all(rs(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSkeleton(context, isDark),
          SizedBox(height: rs(context, 20)),
          _buildSearchSkeleton(context, isDark),
          SizedBox(height: rs(context, 16)),
          ...List.generate(5, (index) => _buildWalletCardSkeleton(context, index, isDark)),
        ],
      ),
    );
  }

  Widget _buildStatisticsSkeleton(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildStatCardSkeleton(context, isDark)),
        SizedBox(width: rs(context, 8)),
        Expanded(child: _buildStatCardSkeleton(context, isDark)),
        SizedBox(width: rs(context, 8)),
        Expanded(child: _buildStatCardSkeleton(context, isDark)),
      ],
    );
  }

  Widget _buildStatCardSkeleton(BuildContext context, bool isDark) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          constraints: BoxConstraints(minHeight: rs(context, 90)),
          decoration: BoxDecoration(
            color: isDark ? Color.lerp(Colors.grey[800], Colors.grey[700], _animation.value) : Color.lerp(Colors.grey[300], Colors.grey[100], _animation.value),
            borderRadius: BorderRadius.circular(rs(context, 12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: rs(context, 4),
                offset: Offset(0, rs(context, 2)),
              ),
            ],
          ),
          padding: EdgeInsets.all(rs(context, 12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: rs(context, 24),
                height: rs(context, 24),
                decoration: BoxDecoration(
                  color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
                  borderRadius: BorderRadius.circular(rs(context, 6)),
                ),
              ),
              SizedBox(height: rs(context, 8)),
              Container(
                width: rs(context, 40),
                height: rs(context, 16),
                color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
              ),
              SizedBox(height: rs(context, 4)),
              Container(
                width: rs(context, 30),
                height: rs(context, 10),
                color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSkeleton(BuildContext context, bool isDark) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: rs(context, 50),
          decoration: BoxDecoration(
            color: isDark ? Color.lerp(Colors.grey[800], Colors.grey[700], _animation.value) : Color.lerp(Colors.grey[300], Colors.grey[100], _animation.value),
            borderRadius: BorderRadius.circular(rs(context, 12)),
          ),
          padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
          child: Row(
            children: [
              Container(
                width: rs(context, 20),
                height: rs(context, 20),
                color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
              ),
              SizedBox(width: rs(context, 12)),
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  height: rs(context, 16),
                  color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletCardSkeleton(BuildContext context, int index, bool isDark) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(bottom: rs(context, 16)),
          constraints: BoxConstraints(minHeight: rs(context, 140)),
          decoration: BoxDecoration(
            color: isDark ? Color.lerp(Colors.grey[800], Colors.grey[700], _animation.value) : Color.lerp(Colors.grey[300], Colors.grey[100], _animation.value),
            borderRadius: BorderRadius.circular(rs(context, 16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: rs(context, 8),
                offset: Offset(0, rs(context, 2)),
              ),
            ],
          ),
          padding: EdgeInsets.all(rs(context, 16)),
          child: Row(
            children: [
              Container(
                width: rs(context, 56),
                height: rs(context, 56),
                decoration: BoxDecoration(
                  color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
                  borderRadius: BorderRadius.circular(rs(context, 14)),
                ),
              ),
              SizedBox(width: rs(context, 12)),
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: rs(context, 100),
                          height: rs(context, 16),
                          color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
                        ),
                        SizedBox(width: rs(context, 8)),
                        Container(
                          width: rs(context, 50),
                          height: rs(context, 18),
                          decoration: BoxDecoration(
                            color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rs(context, 8)),
                    Row(
                      children: [
                        Container(
                          width: rs(context, 16),
                          height: rs(context, 14),
                          color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
                        ),
                        SizedBox(width: rs(context, 8)),
                        Container(
                          width: rs(context, 120),
                          height: rs(context, 12),
                          color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
                        ),
                      ],
                    ),
                    SizedBox(height: rs(context, 12)),
                    Container(
                      padding: EdgeInsets.all(rs(context, 12)),
                      decoration: BoxDecoration(
                        color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[200], Colors.grey[100], _animation.value),
                        borderRadius: BorderRadius.circular(rs(context, 12)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: rs(context, 40),
                                  height: rs(context, 10),
                                  color: isDark ? Color.lerp(Colors.grey[600], Colors.grey[500], _animation.value) : Color.lerp(Colors.grey[500], Colors.grey[300], _animation.value),
                                ),
                                SizedBox(height: rs(context, 6)),
                                Container(
                                  width: rs(context, 60),
                                  height: rs(context, 14),
                                  color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: rs(context, 30),
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                          ),
                          SizedBox(width: rs(context, 12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: rs(context, 35),
                                  height: rs(context, 10),
                                  color: isDark ? Color.lerp(Colors.grey[600], Colors.grey[500], _animation.value) : Color.lerp(Colors.grey[500], Colors.grey[300], _animation.value),
                                ),
                                SizedBox(height: rs(context, 6)),
                                Container(
                                  width: rs(context, 50),
                                  height: rs(context, 14),
                                  color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
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
              SizedBox(width: rs(context, 8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rs(context, 10),
                  vertical: rs(context, 6),
                ),
                decoration: BoxDecoration(
                  color: isDark ? Color.lerp(Colors.grey[700], Colors.grey[600], _animation.value) : Color.lerp(Colors.grey[400], Colors.grey[200], _animation.value),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  width: rs(context, 30),
                  height: rs(context, 12),
                  color: isDark ? Color.lerp(Colors.grey[600], Colors.grey[500], _animation.value) : Color.lerp(Colors.grey[500], Colors.grey[300], _animation.value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
