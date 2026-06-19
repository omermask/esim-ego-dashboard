# دراسة شاملة: العملة الرسمية والتوقيت وإعدادات More

---

## 1. تحليل الوضع الحالي

### العملة (Currency)

| العنصر | الوضع الحالي | المشكلة |
|--------|-------------|---------|
| **العملة الرسمية** | IQD مقسى (hardcoded) في كل مكان | لا يمكن تغييرها |
| **سعر الصرف** | `USD_TO_IQD_RATE = 1500` في config.py (ثابت) | لا يتغير ديناميكيًا |
| **جدول ExchangeRate** | موجود في DB لكن غير مستخدم في تسعير الخطط | غير متكامل مع workflow |
| **MIN/MAX AMOUNT** | `250`, `100,000,000` IQD hardcoded | يخص IQD فقط |
| **المحفظة (Wallet)** | balance/frozen مخزنة بـ IQD فقط | لا تدعم عملات أخرى |
| **الطلبات (Orders)** | `currency="IQD"` hardcoded | لا تدعم عملات أخرى |
| **المدفوعات** | ترفض أي عملة غير IQD | مقفلة على IQD |
| **التقارير المالية** | كلها بـ IQD فقط | لا تدعم عملات أخرى |
| **Pricing أثناء import** | يستخدم `settings.USD_TO_IQD_RATE` (ثابت 1500) | يتجاهل ExchangeRate من DB |

### التوقيت (Timezone)

| العنصر | الوضع الحالي | المشكلة |
|--------|-------------|---------|
| **BAGHDAD_TZ** | `timezone("Asia/Baghdad")` hardcoded في constants.py | لا يقرأ من settings |
| **DEFAULT_TIMEZONE** | موجود في config.py (`Asia/Baghdad`) | غير مستخدم أبدًا |
| **Middleware** | يستخدم BAGHDAD_TZ | لو تغير الإعداد ما ينعكس |
| **Response timestamps** | BAGHDAD_TZ hardcoded | نفس المشكلة |
| **تخزين البيانات** | UTC (صح) | لا مشكلة |
| **خطة المستخدم** | لكل مستخدم حقل timezone | موجود لكن Dashboard لا يستخدمه |

### شاشة More الحالية

| الزر | الحالة |
|------|--------|
| Profile | `onTap: () {}` — **فارغ** |
| Language | يعمل (يغير لغة الواجهة) |
| Dark Mode | يعمل (يغير الثيم) |
| **Settings** | `onTap: () {}` — **فارغ** |
| Logout | يعمل |

---

## 2. التصميم المقترح

### 2.1. نظام العملة الجديد

**A. Server: إعدادات العملة الرسمية (Settings Model جديد)**

```
جدول server_settings:
  - official_currency: String(3) = "IQD"
  - auto_fetch_rates: Boolean = false
  - exchange_rate_api_key: String (optional)
  - timezone: String = "Asia/Baghdad"
  - updated_by: FK → admins.id
  - updated_at: DateTime
```

**B. CurrencyService مطوّر:**

```
CurrencyService:
  - get_official_currency() → "IQD" | "USD" | ...
  - get_rate(base, target) ← يستخدم ExchangeRate table
  - set_rate(base, target, rate, source) ← source可以是 "manual" | "auto"
  - convert(amount, from_currency, to_currency)
  - auto_fetch_rates() ← يستخدم API خارجي (مثلاً exchangerate.host)
  - get_min_amount() / get_max_amount() ← حسب العملة الرسمية
```

**C. Auto-Fetch External APIs (اختياري):**

مصادر مجانية مقترحة:
- `https://api.exchangerate.host/latest?base=USD` (مجاني)
- `https://open.er-api.com/v6/latest/USD` (مجاني)
- `https://api.exchangerate-api.com/v4/latest/USD` (مجاني)

البيانات تُجلب وتُحول إلى `ExchangeRate` records مع `source="auto"`.

**D. تحديث Plan Service:**

```
بدلاً من:
  selling_iqd = round(selling_usd * settings.USD_TO_IQD_RATE)

يصير:
  rate = CurrencyService.get_rate("USD", official_currency)
  selling_official = round(selling_usd * rate)
```

**E. الملفات المتأثرة (Server):**

| الملف | التغيير |
|-------|---------|
| `app/core/constants.py` | إزالة MIN_AMOUNT_IQD, MAX_AMOUNT_IQD ← تصير ديناميكية |
| `app/core/validators.py` | تغيير validators لاستخدام العملة الرسمية ديناميكيًا |
| `app/services/currency_service.py` | إضافة auto_fetch, official_currency, convert |
| `app/services/plan_service.py` | استخدام CurrencyService بدلاً من USD_TO_IQD_RATE |
| `app/services/order_service.py` | استخدام العملة الرسمية بدلاً من IQD hardcoded |
| `app/services/payment_service.py` | تحديث validation لاستخدام العملة الرسمية |
| `app/services/wallet_service.py` | (اختياري) دعم عملات متعددة |
| `app/routes/admin_finance.py` | إضافة endpoints: official_currency, auto_fetch, server_settings |
| `app/models/finance.py` | إضافة ServerSettings model |
| `app/core/constants.py` | إزالة MIN_AMOUNT_IQD, MAX_AMOUNT_IQD |
| `config.py` | إزالة USD_TO_IQD_RATE (اختياري) |

### 2.2. نظام التوقيت الجديد

**A. استبدال BAGHDAD_TZ:**

```
# constants.py
def get_server_timezone() -> pytz.timezone:
    """تقرأ timezone من ServerSettings أو DEFAULT_TIMEZONE"""
    from app.core.database import get_session
    settings = get_server_settings()
    tz_name = settings.timezone if settings else "Asia/Baghdad"
    return pytz.timezone(tz_name)
```

**B. حيث يُستخدم:**

| الموقع | التغيير |
|--------|---------|
| `constants.py` | BAGHDAD_TZ → `get_server_timezone() ` |
| `middleware.py` | يستخدم `get_server_timezone() ` |
| `response.py` | يقرأ `timezone` من settings |
| `plan_service.py` | `datetime.now(SERVER_TZ)` |
| `analytics_service.py` | `datetime.now(SERVER_TZ)` |
| `invoice_service.py` | `datetime.now(SERVER_TZ)` |

### 2.3. شاشة More → Settings

**A. UI الجديد:**

```
More → Settings (الزر الفارغ حالياً) → Currency & Timezone Settings
```

**B. مكونات الشاشة:**

1. **Official Currency Card:**
   - Dropdown لاختيار العملة الرسمية (IQD, USD, EUR, TRY, ...)
   - زر حفظ

2. **Exchange Rate Mode Card:**
   - Toggle: Manual / Auto
   - إذا Auto: حقل API Key (اختياري) + زر "Fetch Now"
   - إذا Manual: قائمة العملات مع إمكانية تعديل السعر يدويًا

3. **Exchange Rates List:**
   - عرض كل العملات المضافة (base → target)
   - إضافة عملة جديدة (+)
   - تعديل سعر
   - حذف عملة

4. **Timezone Card:**
   - Dropdown لاختيار المنطقة الزمنية (قائمة الـ pytz)
   - عرض الوقت الحالي حسب المنطقة المختارة (مع تحديث مباشر)
   - زر حفظ

5. **Server Time Display:**
   - عرض وقت السيرفر الحقيقي حسب المنطقة الزمنية المختارة

**C. API Endpoints جديدة (Server):**

```
GET  /api/v1/admin/settings          →  إعدادات السيرفر
PUT  /api/v1/admin/settings          →  تحديث الإعدادات
GET  /api/v1/admin/settings/timezones →  قائمة المناطق الزمنية
POST /api/v1/admin/exchange-rates/fetch  →  جلب الأسعار تلقائيًا
```

---

## 3. خطة التنفيذ (مرحلية)

### المرحلة 1: Server - إعدادات السيرفر (5-7 أيام)

Files:
- `esim-ego-server/app/models/finance.py` — إضافة `ServerSettings` model
- `esim-ego-server/app/routes/admin_finance.py` — إضافة endpoints للإعدادات
- `esim-ego-server/app/services/currency_service.py` — تطوير شامل
- `esim-ego-server/alembic/versions/` — migration جديد لـ server_settings

### المرحلة 2: Server - تحديث العملة والتوقيت (3-5 أيام)

Files:
- `esim-ego-server/app/core/constants.py` — استبدال BAGHDAD_TZ
- `esim-ego-server/app/core/middleware.py` — استخدام get_server_timezone()
- `esim-ego-server/app/core/response.py` — وقت ديناميكي
- `esim-ego-server/app/core/validators.py` — validators ديناميكية
- `esim-ego-server/app/services/plan_service.py` — استخدام CurrencyService
- `esim-ego-server/app/services/order_service.py` — عملة ديناميكية
- `esim-ego-server/app/services/payment_service.py` — عملة ديناميكية
- `esim-ego-server/config.py` — إزالة USD_TO_IQD_RATE

### المرحلة 3: Flutter - شاشة Settings (3-5 أيام)

Files:
- `app-ego-dashboard/lib/screens/settings/` — مجلد جديد
  - `currency_settings_widget.dart` — إعدادات العملة
  - `timezone_settings_widget.dart` — إعدادات التوقيت
  - `exchange_rates_widget.dart` — إدارة أسعار الصرف
- `app-ego-dashboard/lib/screens/dashboard/dashboard_screen.dart` — ربط زر Settings
- `app-ego-dashboard/lib/data/services/api_service.dart` — endpoints جديدة
- `app-ego-dashboard/lib/data/providers/settings_provider.dart` — Provider للإعدادات

---

## 4. القرارات النهائية (بعد التوضيح)

| السؤال | الإجابة | التأثير |
|--------|---------|---------|
| 1. العملة الرسمية | **عملة واحدة رسمية لكل التطبيق** (IQD/USD/TRY... تُختار من الإعدادات) | كل الخطط، المحفظة، الطلبات، التقارير تستخدم عملة واحدة. التغيير يتم مركزيًا |
| 2. المحفظة | **بنفس العملة الرسمية** | Wallet balance/frozen تكون بالعملة الرسمية فقط |
| 3. API سعر الصرف | **مجاني** (مثلاً exchangerate.host أو open.er-api.com) | auto-fetch يستخدم API مجاني بدون key |
| 4. التوقيت | **توقيت واحد للسيرفر كله** | إعداد عام في ServerSettings، ينطبق على كل middleware و responses |
| 5. توقيت Auto-fetch | **خيارات متعددة:** كل ساعة / كل 6 ساعات / يومي / يدوي / أوتوماتيك | المستخدم يختار من Dropdown في الإعدادات |

## 4b. آلية Auto-Fetch

```
خيارات التحديث (في الإعدادات):
  - Manual: فقط عند الضغط على "Fetch Now"
  - Every Hour: تشغيل Celery task كل ساعة
  - Every 6 Hours: كل 6 ساعات
  - Daily: مرة كل يوم (الساعة 00:00 بتوقيت السيرفر)
  - Auto: يختار السيرفر الأنسب (مثلاً كل 6 ساعات)
```

مصادر API المجانية المقترحة:

| المصدر | الرابط | معدل التحديث | Rate Limit |
|--------|--------|-------------|------------|
| exchangerate.host | `https://api.exchangerate.host/latest?base=USD` | يومي | 1000 req/day |
| open.er-api.com | `https://open.er-api.com/v6/latest/USD` | يومي | غير محدود |
| exchangerate-api.com | `https://api.exchangerate-api.com/v4/latest/USD` | يومي | 1500 req/month |

---

## 5. التحقق والاختبار

1. تأكيد أن `GET /admin/settings` يعيد الإعدادات الحالية
2. تأكيد أن تحديث `official_currency` ينعكس على validators (MIN_AMOUNT, MAX_AMOUNT)
3. تأكيد أن import plan يستخدم سعر الصرف من ExchangeRate table بدلاً من القيمة الثابتة
4. تأكيد أن auto-fetch يجلب الأسعار ويخزنها مع `source="auto"`
5. تأكيد أن ServerSettings.timezone يؤثر على middleware timestamps
6. تأكيد أن Flutter Settings screen يقرأ ويعدّل كل الإعدادات
