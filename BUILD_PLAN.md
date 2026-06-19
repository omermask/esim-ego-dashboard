# خطة بناء شاشات لوحة تحكم الأدمن

## 🏗️ بنية التنقل (Navigation Architecture)

### الهيكل العام
```
DashboardScreen (bottom nav × 5)
├── _HomeTab           ← Overview التحليلات
├── _PlansTab          ← الخطط (sub-page: grid→all/create/inventory/pricing/catalogue/detail)
├── _OrdersTab         ← الطلبات (sub-page: grid→sub-screens)
├── _UsersTab          ← المستخدمين (sub-page: grid→sub-screens)
└── _MoreTab           ← المزيد (sub-page: 0=menu, 1..N=settings/support/etc)
```

### نمط التنقل الموحد لكل تبويب
كل تبويب يستخدم `_subPage` (int) بدلاً من `Navigator.push` ليظل **داخل البار السفلي**:

```
class _XxxTabState extends State<_XxxTab> {
  int _subPage = 0;
  int _prevSubPage = 0;

  void _open(int page) => setState(() { _prevSubPage = _subPage; _subPage = page; });
  void _back() => setState(() { _subPage = _prevSubPage; });

  Widget build() {
    switch (_subPage) {
      case 0: return _buildGrid();       // الشاشة الرئيسية (شبكة الأقسام)
      case 1: return _buildAllList();     // القائمة الكاملة
      case 2: return _buildCreateForm();  // نموذج إنشاء جديد
      case 3: return _buildDetail(model); // تفاصيل عنصر
    }
  }
}
```

### تمرير البيانات بين الشاشات الفرعية
- الـ tabs كلها داخل `DashboardScreen` → `IndexedStack` → الحالة محفوظة
- `_OrdersTab` و `_UsersTab` و `_MoreTab` يحتاجون `_subPage` مثل `_PlansTab`
- زر الرجوع: `_backToGrid()` يعيدك لصفحة الشبكة في نفس التبويب

---

## 📋 قائمة الشاشات كاملة (حسب الأولوية)

### [P0] الأساسيات — يجب اكتمالها أولاً

| # | الشاشة | الموديل | البروفايدر | الحالة |
|---|--------|---------|------------|--------|
| 1 | **All Orders** (قائمة الطلبات) | `AdminOrder` | `OrdersProvider` ❌ | غير مسجل |
| 2 | **All Users** (قائمة المستخدمين) | `AdminUser` | `UsersProvider` ❌ | غير مسجل |
| 3 | **Support Tickets** (التذاكر) | `AdminTicket` | `SupportProvider` ❌ | غير مسجل |
| 4 | **Wallet Dashboard** (المحفظة) | `WalletData` | لا يوجد | لا يوجد |
| 5 | **Inventory** (المخزون) | `ImportBatch` | `InventoryProvider` ❌ | موجود جزئياً |

### [P1] الشاشات المالية

| # | الشاشة | الموديل | البروفايدر |
|---|--------|---------|------------|
| 6 | **Payments** (المدفوعات) | `AdminPayment` | `PaymentsProvider` ❌ |
| 7 | **Coupons** (كوبونات الخصم) | `CouponData` | `CouponProvider` ❌ |
| 8 | **Tax Rates** (الضرائب) | `TaxRateData` | `TaxRateProvider` ❌ |
| 9 | **Refunds** (المبالغ المستردة) | `RefundData` | `RefundProvider` ❌ |
| 10 | **Financial Reports** (التقارير المالية) | `FinancialReport` | `ReportProvider` ❌ |

### [P2] الشاشات الإدارية

| # | الشاشة | الموديل | البروفايدر |
|---|--------|---------|------------|
| 11 | **Freezes** (التجميد) | `FreezeData` | `FreezeProvider` ❌ |
| 12 | **Referrals** (الإحالات) | `ReferralReward` | `ReferralProvider` ❌ |
| 13 | **Backups** (النسخ الاحتياطي) | `BackupRecord` | `BackupProvider` ❌ |
| 14 | **Audit Log** (سجل التدقيق) | `AuditLogEntry` | `AuditLogProvider` ❌ |
| 15 | **2FA Setup** (التحقق بخطوتين) | — | `TwoFAProvider` ❌ |

---

## 🧱 Phase 0: تسجيل جميع البروفايدرات (فوري)

**الملف:** `main.dart` — أضف إلى `MultiProvider`:

```
OrdersProvider, UsersProvider, SupportProvider, PaymentsProvider,
CouponProvider, TaxRateProvider, RefundProvider, FreezeProvider,
InventoryProvider, ReferralProvider, ReportProvider, BackupProvider,
AuditLogProvider, TwoFAProvider
```

**ملاحظة:** `WalletData` ليس له بروفايدر — أنشئ `WalletProvider` جديد.

---

## 📱 Phase 1: Orders Tab (الطلبات)

### الشاشة الرئيسية: `_OrdersTab._buildGrid()`
شبكة 3 أعمدة مثل `_PlansTab`:
- 🟢 **All Orders** → قائمة كاملة
- 🟡 **Transactions** → سجل المعاملات
- 🔵 **Manual Deposit** → إيداع يدوي
- 🟣 **Exchange** → تحويل عملات

### Screen: `order_list_widget.dart`
| العنصر | التفاصيل |
|--------|----------|
| header | عنوان + شريط بحث + فلتر (الكل/معلق/مكتمل/ملغي) |
| list | PaginatedListView مع `OrdersProvider` |
| item | رقم الطلب + المستخدم + المبلغ + الحالة + التاريخ |
| actions | زر موافقة/إلغاء لكل طلب pending |
| detail | `Navigator.push` إلى صفحة تفاصيل |

### Screen: `order_detail_widget.dart`
- معلومات العميل، المنتج، السعر، الحالة، وقت الإنشاء
- زر تحديث الحالة (Approve/Cancel)
- سجل التحديثات

### Screen: `transaction_list_widget.dart`
- جميع حركات المحفظة مع التصفية حسب النوع
- `WalletTransaction` model + API

### Screen: `manual_deposit_widget.dart`
- فورم: اختيار مستخدم، إدخال المبلغ، سبب الإيداع
- API: `api.manualDeposit()`

### Screen: `exchange_rates_widget.dart` (موجود جزئياً)
- قائمة أسعار الصرف من `ExchangeRateProvider`
- زر Fetch Now
- تعديل سعر يدوي

---

## 👥 Phase 2: Users Tab (المستخدمين)

### الشاشة الرئيسية: `_UsersTab._buildGrid()`
شبكة 3 أعمدة:
- 🟢 **All Users** → قائمة المستخدمين
- 🟡 **KYC** → طلبات التحقق
- 🔵 **Tickets** → تذاكر الدعم
- 🟣 **Wallets** → محافظ المستخدمين
- ⚪ **Cards** → البطاقات
- 🔴 **Activity** → سجل النشاط

### Screen: `user_list_widget.dart`
| العنصر | التفاصيل |
|--------|----------|
| header | عنوان + بحث + فلتر (الكل/نشط/موقف) |
| list | PaginatedListView مع `UsersProvider` |
| item | صورة + اسم + هاتف + بريد + حالة + رصيد |
| actions | تفعيل/إيقاف، تغيير الدور |

### Screen: `user_detail_widget.dart`
- جميع معلومات المستخدم
- المحفظة والرصيد
- الطلبات السابقة
- سجل النشاط (Activity Log)
- أزرار: إيقاف/تفعيل، حظر، تغيير كلمة المرور

### Screen: `kyc_requests_widget.dart`
- قائمة طلبات KYC معلقة
- عرض الوثائق (صور، هوية)
- زر موافقة/رفض مع سبب

### Screen: `support_tickets_widget.dart`
- قائمة التذاكر مع `SupportProvider`
- فلتر: مفتوح/مغلق/كل التذاكر
- الضغط على تذكرة → صفحة محادثة: `ticket_detail_widget.dart`
- إرسال رد + إغلاق التذكرة

### Screen: `user_wallet_widget.dart`
- محفظة مستخدم + سجل الحركات
- إيداع/سحب يدوي

---

## 🔧 Phase 3: More Tab (المزيد)

### هيكل `_MoreTab._moreSubPage`
```dart
int _moreSubPage = 0;
// 0 = القائمة الرئيسية
// 1 = Server Settings ✓ (موجود)
// 2 = Payments
// 3 = Coupons
// 4 = Tax Rates
// 5 = Refunds
// 6 = Referrals
// 7 = Reports
// 8 = Backups
// 9 = Audit Log
// 10 = 2FA Setup
// 11 = النظام (System Settings)
```

### Screens الجديدة في More:

| الرقم | الشاشة | الملف | الوصف |
|-------|--------|-------|-------|
| 2 | **Payments** | `more/payments_widget.dart` | قائمة المدفوعات + تأكيد يدوي |
| 3 | **Coupons** | `more/coupons_widget.dart` | إدارة كوبونات الخصم (CRUD) |
| 4 | **Tax Rates** | `more/tax_rates_widget.dart` | إدارة الضرائب |
| 5 | **Refunds** | `more/refunds_widget.dart` | طلبات الاسترداد + موافقة/رفض |
| 6 | **Referrals** | `more/referrals_widget.dart` | إعدادات الإحالة + المكافآت |
| 7 | **Reports** | `more/reports_widget.dart` | تقارير مالية (رسم بياني + جدول) |
| 8 | **Backups** | `more/backups_widget.dart` | نسخ احتياطي + إنشاء/استعادة/حذف |
| 9 | **Audit Log** | `more/audit_log_widget.dart` | سجل جميع العمليات |
| 10 | **2FA** | `more/twofa_setup_widget.dart` | إعداد/تعطيل التحقق بخطوتين |

---

## 🎨 Phase 4: التصميم الموحد

### نمط كل شاشة

```dart
Widget _buildScreen(String title, Widget body) {
  return SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(rs(20), rs(16), rs(20), rs(100)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: rs(24)),
      // رأس الصفحة
      Row(
        children: [
          // زر الرجوع
          if (_subPage > 0)
            InkWell(
              onTap: _back,
              child: SvgPicture.asset('assets/icons/rightArrow.svg',
                width: rs(22), colorFilter: ColorFilter.mode(dc.textPrimary, BlendMode.srcIn)),
            ),
          SizedBox(width: rs(12)),
          Text(title, style: TextStyle(fontSize: rs(24), fontWeight: FontWeight.w700, color: dc.textPrimary)),
        ],
      ),
      SizedBox(height: rs(24)),
      body,
    ]),
  );
}
```

### Card موحد للقوائم
```dart
Container(
  decoration: BoxDecoration(
    color: dc.bg,
    borderRadius: BorderRadius.circular(rs(20)),
    border: Border.all(color: dc.borderColor.withValues(alpha: 0.3), width: 1),
  ),
  padding: EdgeInsets.all(rs(14)),
  child: Column(...),
)
```

### عناصر القائمة (ListTile موحد)
- أيقونة SVG في `Container` بحجم 44×44 مع لون `dc.iconBox`
- عنوان + نص فرعي
- سهم يمين (`rightArrow.svg`)
- `InkWell` مع `onTap`

### صفحة تحميل + خطأ موحدة
- `CustomLoader()` للتحميل
- `ErrorMessage` أو `EmptyState` للخطأ/الفارغ
- `RefreshIndicator` مع `_refresh`

---

## 🔔 Phase 5: الإشعارات

### خيارات التنفيذ:
1. **In-app notifications** (أسهل): `OverlayEntry` أو `CustomToaster` موجود
2. **Notification bell** في رأس `_HomeTab` عند الحاجة
3. **Socket.IO** (موجود في `app.socketio` على السيرفر):
   - يستقبل أحداث: طلب جديد، دفعة جديدة، تذكرة دعم جديدة
   - `socketio_service.dart` في Flutter يتصل بالـ Namespace
   - يعرض badge على الأيقونة في الـ bottom nav
4. **FCM (Firebase)** لأول إصدار لاحق

### تنبيهات داخلية:
- إشعار عند فشل عملية مهمة
- Toast نجاح/خطأ موجود بالفعل عبر `CustomToaster`

---

## 🗺️ خريطة التنقل الكاملة

```
PhoneEntryScreen
  └── OtpVerificationScreen
       └── TwoFactorScreen
            └── DashboardScreen (bottom nav)
                 ├── Home (Overview)
                 │    ├── Dashboard stats cards
                 │    ├── Sales chart (fl_chart)
                 │    ├── Plans chart (fl_chart)
                 │    └── User growth chart
                 │
                 ├── Plans
                 │    ├── [Grid] Plan Management
                 │    ├── [1] All Plans → plan detail
                 │    ├── [2] Create Plan
                 │    ├── [3] Inventory
                 │    ├── [4] Pricing
                 │    └── [5] Provider Catalogue
                 │
                 ├── Orders
                 │    ├── [Grid] Order Management
                 │    ├── [1] All Orders → order detail
                 │    ├── [2] Transactions
                 │    ├── [3] Manual Deposit
                 │    └── [4] Exchange Rates
                 │
                 ├── Users
                 │    ├── [Grid] User Management
                 │    ├── [1] All Users → user detail
                 │    ├── [2] KYC Requests
                 │    ├── [3] Support Tickets → ticket chat
                 │    ├── [4] Wallets
                 │    ├── [5] Cards
                 │    └── [6] Activity Log
                 │
                 └── More
                      ├── [0] Menu
                      │    ├── Profile
                      │    ├── Language
                      │    ├── Dark Mode
                      │    ├── Settings → [1] Server Settings
                      │    ├── Payments → [2]
                      │    ├── Coupons → [3]
                      │    ├── Tax Rates → [4]
                      │    ├── Refunds → [5]
                      │    ├── Referrals → [6]
                      │    ├── Reports → [7]
                      │    ├── Backups → [8]
                      │    ├── Audit Log → [9]
                      │    ├── 2FA → [10]
                      │    └── Logout
                      └── [1..10] شاشات الإعدادات والمالية
```

---

## 📦 ترتيب التنفيذ المقترح

| المرحلة | المدة | المهام |
|---------|-------|--------|
| **P0.1** | 30 د | تسجيل providers الـ 9 في main.dart |
| **P0.2** | 1 س | إضافة `WalletProvider` + API methods |
| **P1** | 3 س | Orders Tab: list + detail + transactions + deposit + exchange |
| **P2** | 4 س | Users Tab: list + detail + KYC + tickets + wallets |
| **P3** | 4 س | More Tab: payments + coupons + tax + refunds + referrals + reports |
| **P4** | 3 س | More Tab: backups + audit + 2FA + باقي الشاشات |
| **P5** | 2 س | إشعارات + Socket.IO + Badge + تحسينات UI |
| **P6** | 1 س | اختبار شامل + fix bugs + توحيد الألوان والهوامش |

**المجموع التقريبي:** ~18 ساعة عمل

---

## 🧩 أنماط التكرار (Code Patterns)

### Paginated List
```dart
// كل شاشة قائمة تتبع هذا النمط:
final provider = context.watch<XxxProvider>();
final items = provider.items;
final loading = provider.loading;
final hasMore = provider.hasMore;

NotificationListener<ScrollNotification>(
  onNotification: (s) {
    if (s is ScrollEndNotification && !loading && hasMore) {
      provider.loadMore();
    }
    return false;
  },
  child: ListView.builder(
    itemCount: items.length + (hasMore ? 1 : 0),
    itemBuilder: (ctx, i) => _buildItem(items[i]),
  ),
);
```

### Search + Filter
```dart
String _query = '';
String _filter = 'all';

TextField(
  onChanged: (v) => setState(() => _query = v),
  decoration: InputDecoration(
    prefixIcon: SvgPicture.asset(AppIcons.search, ...),
    hintText: trans(context, 'Search'),
  ),
);
FilterChipsRow(
  items: ['All', 'Active', 'Inactive'],
  selected: _filter,
  onChanged: (v) => setState(() => _filter = v),
);
```

### Form Submission
```dart
bool _saving = false;

Future<void> _save() async {
  setState(() => _saving = true);
  final err = await provider.create(data);
  if (mounted) {
    setState(() => _saving = false);
    if (err == null) {
      context.showSuccess(trans(context, 'Created successfully'));
      _back();
    } else {
      context.showError(err);
    }
  }
}
```
