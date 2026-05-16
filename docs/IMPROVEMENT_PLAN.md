# Kế hoạch hoàn thiện & tối ưu PicFi

## Trạng thái hiện tại

### 3 nhánh phát triển song song (chưa merge)

| Nhánh | Commit | Tính năng |
|-------|--------|-----------|
| **main** | `97f2f4f` | FCM notifications, offline mode, deep linking, iMessage auth, performance optimization |
| **Kha** | `82c4cf2` | Gamification/achievements, CSV/Excel export, app lock, home widget |
| **Liem** | `796c279` | Premium subscription, AI chatbot/OCR, advanced analytics, security |

---

## MỤC 1: NHỮNG THỨ CẦN SỬA NGAY (BUGS & STUBS)

### 1.1 Forgot Password — đang là no-op
- **File**: `lib/presentation/screens/auth/login_screen.dart:174`
- **Vấn đề**: `onPressed: () {}`
- **Fix**: Gọi `FirebaseAuth.instance.sendPasswordResetEmail(email)`, thêm dialog xác nhận

### 1.2 Edit Expense — đang là no-op
- **File**: `lib/presentation/screens/expense/expense_detail_screen.dart:270`
- **Vấn đề**: `onTap: () {}`
- **Fix**: Mở `AddExpenseScreen` ở chế độ edit với expenseId hoặc tạo `EditExpenseScreen`

### 1.3 Google Sign-In — đang throw error stub
- **File**: `lib/presentation/blocs/auth/auth_cubit.dart:200`
- **Vấn đề**: `emit(state.copyWith(error: 'Google Sign-In chưa được cấu hình SHA-1'))`
- **Fix**: Implement real Google Sign-In với `GoogleSignIn` package (đã có trong pubspec)

### 1.4 Income Tracking — hardcoded 24,000,000 VND
- **File**: `lib/presentation/blocs/expense/expense_cubit.dart:94`
- **Vấn đề**: `totalIncome: 24000000` — hardcoded
- **Fix**: Tạo Income entity → Firestore collection → user configurable trong Profile

### 1.5 Weekly Bar Chart — mock data
- **File**: `lib/presentation/screens/stats/statistics_screen.dart:321`
- **Vấn đề**: 4 bars hardcoded (3, 5, 8, 4)
- **Fix**: Tính toán từ real expense data trong 7 ngày gần nhất

### 1.6 Offline Action Executors — empty stubs
- **File**: `lib/presentation/blocs/connectivity/connectivity_cubit.dart:33-42`
- **Vấn đề**: `switch` cases có `break` nhưng không có logic
- **Fix**: Implement actual Firestore operations khi online trở lại

### 1.7 Feed Comments — "coming soon"
- **File**: `lib/presentation/screens/feed/feed_screen.dart:465`
- **Vấn đề**: Snackbar placeholder
- **Fix**: Implement comments subcollection trong Firestore

### 1.8 Feed Fire Reactions — không persist
- **File**: `lib/presentation/screens/feed/feed_screen.dart:474`
- **Vấn đề**: Chỉ snackbar, không lưu Firestore
- **Fix**: Lưu reactions vào Firestore subcollection

### 1.9 Onboarding — hiện mỗi lần mở app
- **File**: `lib/presentation/screens/splash/splash_screen.dart`
- **Vấn đề**: Không check SharedPreferences
- **Fix**: Lưu `hasSeenOnboarding = true` sau khi hoàn tất, check ở splash

---

## MỤC 2: CẦN MERGE CÁC NHÁNH

Hiện tại 3 nhánh đã diverge. Các shared file bị conflicted:

| File | main | Kha | Liem |
|------|------|-----|------|
| `app_router.dart` | Routes cơ bản + profile | Thêm routes | Thêm premium/ai routes |
| `main.dart` | Thêm services | Thêm blocs | Thêm premium/ai blocs |
| `profile_screen.dart` | Base | Thêm export/achievement | Thêm premium/ai/security |
| `app_strings.dart` | Notifications + offline | — | Thêm premium/ai/security |

**Cần merge** tất cả lên `main` theo thứ tự:
1. Merge Kha → main (gamification, app lock, CSV export, home widget)
2. Merge Liem → main (premium, AI, analytics, security)
3. Giải quyết conflicts ở các shared files

---

## MỤC 3: TÍNH NĂNG CÒN THIẾU

### 3.1 Email Verification
- Sau signup, gửi email verify
- Chặn login nếu chưa verify
- UI: resend email, check status

### 3.2 Notification List Screen
- Màn hình thông báo (bell icon ở Home)
- List real notifications từ Firestore
- Mark as read, clear all
- Deep link navigate khi tap

### 3.3 Date Range Filter
- `lib/presentation/screens/expense/expense_list_screen.dart`
- Thêm DateRangePicker để filter expenses
- Filter theo: Hôm nay, Tuần này, Tháng này, Khoảng thời gian

### 3.4 Income Management
- Income entity + Firestore collection
- Màn hình thêm/sửa/xóa income
- Tính balance từ totalIncome - totalExpense thực tế

### 3.5 Multi-currency Support
- Thêm currency field vào ExpenseEntity
- Exchange rate service (API)
- Currency selector khi thêm expense

### 3.6 AddExpenseScreen Edit Mode
- Cho phép edit expense hiện có thay vì chỉ tạo mới
- Load existing data vào form
- Update thay vì create trên Firestore

### 3.7 Search by Date Range (hiện chỉ search text)
- `expense_list_screen.dart` có search bar text-only
- Thêm date range chips / DateRangePicker

### 3.8 Recurring Expenses
- Entity: RecurringExpense (interval, nextDate, endDate)
- Background service check hàng ngày
- Auto-create expense khi đến hạn
- UI: recurring toggle + interval picker

### 3.9 Budget Edit/Delete UI
- `budget_cubit.dart` có updateBudgetLimit và deleteBudget
- Nhưng Profile chỉ có dialog create budget
- Thêm edit/delete actions vào budget list

### 3.10 Chat Image from Gallery
- `chat_screen.dart` chỉ có camera để gửi ảnh
- Thêm option: chụp ảnh / chọn từ thư viện

---

## MỤC 4: TỐI ƯU HIỆU NĂNG

### 4.1 Shimmer/Skeleton Loading
- Hầu hết screens dùng `BlocBuilder` nhưng không có loading state
- Thêm `ShimmerLoading` widget (đã có ở Kha branch) cho:
  - HomeScreen balance card
  - FeedScreen list
  - FriendsScreen list
  - StatisticsScreen charts

### 4.2 Pagination
- Feed và Expense List load toàn bộ dữ liệu
- Implement Firestore pagination: `limit() + startAfter()`
- Load more khi scroll gần cuối

### 4.3 Image Optimization
- `flutter_image_compress` đã có trong pubspec nhưng chưa dùng
- Nén ảnh trước khi upload lên Firebase Storage
- Resize ảnh thumbnail riêng cho list view

### 4.4 Debounce Search
- Search expense hiện tại gọi Firestore ngay khi gõ
- Apply Debouncer (đã có) cho search input

### 4.5 Lazy Loading Screens
- MainScreen load tất cả tabs cùng lúc
- Dùng `AutomaticKeepAliveClientMixin` + lazy init cho tabs

---

## MỤC 5: UX & UI

### 5.1 Empty States
- Hiện tại chỉ có text "Chưa có dữ liệu"
- Thêm illustration + CTA button cho mỗi empty state:
  - No expenses → "Thêm chi tiêu đầu tiên"
  - No friends → "Kết bạn ngay"
  - No feed → "Chia sẻ khoảnh khắc"

### 5.2 Haptic Feedback
- Đã dùng `HapticFeedback.lightImpact()` ở một số chỗ
- Thêm đầy đủ cho: button press, swipe actions, toggle switches

### 5.3 Swipe to Delete
- Expense list: swipe left → delete
- Notification list: swipe → mark read / delete
- Friend list: swipe → unfriend

### 5.4 Pull to Refresh
- Feed, Expense List, Friends chưa có pull-to-refresh
- Dùng `RefreshIndicator` + reload từ Firestore

### 5.5 Dark Mode Consistency
- `main_screen.dart` không dùng theme cubit
- Offline banner, nav bar không adapt với dark mode
- Fix: dùng `context.watch<ThemeCubit>()`

---

## MỤC 6: BẢO MẬT & ỔN ĐỊNH

### 6.1 Firestore Security Rules
- Hiện tại code client-side, không có rules
- Viết rules cho:
  - users/{userId}: chỉ owner
  - expenses/{expenseId}: owner + friends (shared)
  - feed/{postId}: owner + friends
  - chats/{chatId}: participants only

### 6.2 Firebase Crashlytics
- Thêm `firebase_crashlytics` vào pubspec
- Configure trong main()
- Log errors ở tất cả catch blocks

### 6.3 Input Validation
- `add_expense_screen.dart`: amount có thể là "0"
- Validate: amount > 0, note length, image required
- Show specific error messages

### 6.4 Rate Limiting
- Friend request spam protection
- Limit: tối đa N requests/giờ
- Store request count trong Firestore

---

## MỤC 7: TESTING

### 7.1 Unit Tests
- AuthCubit tests: signIn, signUp, validation
- ExpenseCubit tests: CRUD operations
- BudgetCubit tests: limit checking
- Utility tests: currency_format, date_format

### 7.2 Widget Tests
- LoginScreen: form validation, button states
- AddExpenseScreen: category selection, photo picker
- HomeScreen: balance display, expense list

### 7.3 Integration Tests
- Full auth flow: register → login → main screen
- Expense flow: add → list → detail → delete
- Friends flow: send request → accept → chat

---

## MỤC 8: CI/CD & DEPLOY

### 8.1 GitHub Actions
- CI: `flutter analyze` + `flutter test` trên mỗi PR
- CD: build APK/AAB tự động khi push tag

### 8.2 Code Generation (optional)
- `json_serializable` cho entities
- `freezed` cho state classes
- `injectable` cho dependency injection

### 8.3 Localization
- Hiện tại full Vietnamese, hardcoded trong code
- Dùng `flutter_localizations` + ARB files
- Support English như ngôn ngữ thứ 2

---

## ƯU TIÊN THỰC HIỆN

### Phase 1 — Critical (1-2 days)
1. Sửa các no-op: forgot password, edit expense
2. Merge Kha → main (gamification, lock, export)
3. Merge Liem → main (premium, AI, analytics)

### Phase 2 — Core Features (3-5 days)
1. Income management thay cho hardcoded
2. Email verification flow
3. Notification list screen
4. Date range filter
5. Recurring expenses

### Phase 3 — UX/UI (2-3 days)
1. Empty states + illustrations
2. Shimmer loading
3. Pull to refresh
4. Swipe actions
5. Dark mode consistency

### Phase 4 — Optimization (2-3 days)
1. Pagination
2. Image compression
3. Debounce search
4. Security rules
5. Firebase Crashlytics

### Phase 5 — Testing & Deploy (3-5 days)
1. Unit tests
2. Widget tests
3. CI/CD pipeline
4. Localization
5. Build & deploy
