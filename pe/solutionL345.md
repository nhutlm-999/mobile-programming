# BỘ RESOURCE TỔNG HỢP FLUTTER + SQLITE + RIVERPOD (LAB 3, LAB 4, LAB 5 & ĐỀ THI PE)
*(Thiết kế theo đúng cấu trúc và tư duy logic của project `sqlite_intro` — Đơn giản, Generic, Dễ dàng tùy biến cho mọi dạng đề)*

---

## 1. Điểm Chung Cốt Lõi Của Cả 3 Bài Lab & Cách Dùng Bộ Resource Này

Khi phân tích **Lab 3 (Computer Store)**, **Lab 4 (Recurring Bills)** và **Lab 5 (Favorite Shopping Items)**, mọi đề bài đều xoay quanh **7 mảnh ghép chuẩn**:

| Mảnh ghép | Lab 3 (Computer Store) | Lab 4 (Recurring Bills) | Lab 5 (Shopping Items) | Đề mở rộng có Auth |
| :--- | :--- | :--- | :--- | :--- |
| **1. Auth** | Không yêu cầu | Không yêu cầu | Không yêu cầu | **Login / Register** (`users` table) |
| **2. Bảng chính** | `computers` (nhiều cột + FK) | `bills` (`bill_name`, `category`, `amount`, `status`, `due_date`) | `shopping_items` (`itemName`, `category`, `price`, `status`) | Bất kỳ thực thể nào (`books`, `cars`, `tasks`...) |
| **3. Bảng phụ (1-N)** | `brands`, `categories` (có `LEFT JOIN` đếm số SP & chặn xóa) | Dropdown `category` cố định | Dropdown `category` cố định | Có hoặc không |
| **4. Home Screen** | `AppBar` + **Banner** + Search/Filter/Sort + `ListView.builder` | `AppBar` + **Banner** + `ListView.builder` + Empty State + `FAB (+)` | `AppBar` + **Banner** + `ListView.builder` + Empty State + `FAB (+)` | Giống hệt + nút Logout |
| **5. Add / Edit Form** | Text + Dropdown từ DB + Switch + Validate số/trùng tên | Text + Dropdown + **DatePicker (`YYYY-MM-DD`)** + Status mặc định `"Unpaid"` + 3 nút (`Update`, `Delete`, `Back`) | Text + Dropdown + Status mặc định `"Wishlist"` + 2 nút (`Save`, `Cancel`) | Đầy đủ các kiểu input |
| **6. Detail / Action** | Xem chi tiết + Tính `Revenue`, `Inventory Value`, `Total Units` + Edit/Delete | Bấm vào item mở thẳng màn Update (có nút Delete + Back) | Xem chi tiết + 3 nút cùng hàng: **Toggle Status (`Wishlist ↔ Purchased`)**, `Delete`, `Back` | Hỗ trợ cả 2 kiểu |
| **7. Summary / Stats** | Tab `Statistics` (`COUNT`, `SUM`, `AVG`, `GROUP BY`) + Tab `Featured` | Tab `Unpaid Bills` (Lọc `status = 'Unpaid'` + tính **Tổng tiền** ở đáy màn hình) | Tab `Wishlist` (Lọc `status = 'Wishlist'` + tính **Tổng tiền** ở đáy màn hình) | Tab Summary / Statistics |

### Cấu trúc thư mục chuẩn (Giữ nguyên từ `sqlite_intro`)
```text
lib/
├── main.dart
├── utils/
│   ├── app_validators.dart      # Bộ Validate đa năng cho mọi kiểu dữ liệu (String, Int, Double, Date, Regex, Email...)
│   └── dialog_helper.dart       # AlertDialog (Validation, Confirm Delete, Success), SnackBar, DatePicker
├── model/
│   ├── app_user.dart            # Model User cho Login / Register
│   ├── category_group.dart      # Model bảng cha 1-N (Brand / Category - dùng khi đề có nhiều bảng như Lab 3)
│   └── item_record.dart         # Model bảng chính Generic (Computer / Bill / ShoppingItem)
├── db/
│   └── database_helper.dart     # Singleton DatabaseHelper (Auth + CRUD + Toggle + Join + Filter + Sum/Stats)
├── providers/
│   └── app_providers.dart       # Toàn bộ Riverpod Notifier gom gọn vào 1 file (không phụ thuộc build_runner!)
└── ui/
    ├── login_screen.dart        # Màn hình Login & Register
    ├── main_tab_screen.dart     # BottomNavigationBar chuyển tab
    ├── home_list_screen.dart    # Màn hình chính: Banner + Search/Filter/Sort + ListView + FAB
    ├── item_form_screen.dart    # Màn hình Add / Update (Text, Dropdown, DatePicker, Switch, 3 buttons)
    ├── item_detail_screen.dart  # Màn hình Detail (Full info +的计算 + Toggle Status / Edit / Delete / Back)
    ├── summary_stats_screen.dart# Màn hình Summary (Lab 4, 5) + Statistics (Lab 3)
    └── group_manage_screen.dart # Màn hình CRUD bảng cha 1-N (Brand/Category - Lab 3)
```

> [!TIP]
> **Mẹo cực quan trọng khi đi thi**: Trong `sqlite_intro`, file `note_notifier.dart` dùng `@riverpod` cần chạy `dart run build_runner build`. Tuy nhiên nếu lúc thi bạn đổi tên class/model mà quên chạy `build_runner` sẽ bị báo lỗi đỏ. Vì vậy trong bộ Resource này, mình cung cấp **cả 2 cách** (cách dùng `@riverpod` generator và cách viết trực tiếp `AsyncNotifierProvider` của `flutter_riverpod` không cần chạy `build_runner`) để bạn copy vào là chạy ngay 100%!

---

## 2. File `lib/utils/app_validators.dart` — Bộ Validate Đa Năng (Cover Mọi Dạng Đề)

Copy nguyên file này để dùng cho mọi `TextFormField` và `DropdownButtonFormField`. Đã bao phủ:
- Chuỗi bắt buộc (`required`), giới hạn độ dài (`length`), mã định dạng Regex (`pattern` - ví dụ mã sinh viên `SE123456`, biển số, mã hóa đơn).
- Email, Password, Confirm Password, Số điện thoại.
- Số nguyên (`intNumber`): `> 0`, `>= 0`, `> 1900`, nằm trong khoảng `[min, max]`, số chẵn / chia hết (ví dụ RAM chia hết cho 4).
- Số thực (`doubleNumber`): `> 0`, `>= 0`, nằm trong khoảng `[min, max]`.
- Ngày tháng (`isoDate`): đúng chuẩn `YYYY-MM-DD`, không ở quá khứ, không ở tương lai, hoặc so sánh `endDate >= startDate`.

```dart
class AppValidators {
  /// 1. Bắt buộc nhập (Chuẩn thông báo Figure 2 Lab 4 & Lab 5: "Please enter ...")
  static String? required(String? value, [String fieldName = 'this field']) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  /// 2. Độ dài chuỗi (Min / Max)
  static String? length(
    String? value, {
    required String fieldName,
    int min = 1,
    int? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    final len = value.trim().length;
    if (len < min) {
      return '$fieldName must be at least $min characters';
    }
    if (max != null && len > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }

  /// 3. Kiểm tra theo Regex bất kỳ (Ví dụ: Mã SP 'CP-1234', Mã SV 'SE190321')
  static String? pattern(
    String? value, {
    required String fieldName,
    required RegExp regex,
    required String errorMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    if (!regex.hasMatch(value.trim())) {
      return errorMessage;
    }
    return null;
  }

  /// 4. Email chuẩn (Dùng cho Login / Register)
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Invalid email format (e.g. user@fpt.edu.vn)';
    }
    return null;
  }

  /// 5. Password & Confirm Password
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != originalPassword) {
      return 'Confirm password does not match';
    }
    return null;
  }

  /// 6. Số điện thoại (10 - 11 chữ số, bắt đầu bằng 0)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    if (!RegExp(r'^0\d{9,10}$').hasMatch(value.trim())) {
      return 'Phone must start with 0 and contain 10-11 digits';
    }
    return null;
  }

  /// 7. Số nguyên (INT) - Dùng cho RAM, Storage, Stock, Sold Quantity, Founded Year...
  static String? intNumber(
    String? value, {
    required String fieldName,
    int? min,          // Ví dụ: Stock >= 0 -> min: 0; RAM 4..128 -> min: 4, max: 128
    int? max,
    int? greaterThan,  // Ví dụ: Founded Year > 1900 -> greaterThan: 1900
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    final number = int.tryParse(value.trim());
    if (number == null) {
      return '$fieldName must be a valid integer';
    }
    if (greaterThan != null && number <= greaterThan) {
      return '$fieldName must be greater than $greaterThan';
    }
    if (min != null && number < min) {
      return '$fieldName must be >= $min';
    }
    if (max != null && number > max) {
      return '$fieldName must be <= $max';
    }
    return null;
  }

  /// 8. Số thực (REAL / DOUBLE) - Dùng cho Price (Lab 3, 5), Amount (Lab 4)...
  static String? doubleNumber(
    String? value, {
    required String fieldName,
    bool strictlyPositive = true, // Price > 0
    double? min,
    double? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    if (strictlyPositive && number <= 0) {
      return '$fieldName must be > 0';
    }
    if (min != null && number < min) {
      return '$fieldName must be >= $min';
    }
    if (max != null && number > max) {
      return '$fieldName must be <= $max';
    }
    return null;
  }

  /// 9. Ngày tháng ISO 'YYYY-MM-DD' (Dùng cho Due Date của Lab 4)
  static String? isoDate(
    String? value, {
    String fieldName = 'Due Date',
    bool mustNotBePast = false,
    bool mustNotBeFuture = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select $fieldName';
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim())) {
      return '$fieldName must be in YYYY-MM-DD format';
    }
    final date = DateTime.tryParse(value.trim());
    if (date == null) {
      return 'Invalid $fieldName';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (mustNotBePast && date.isBefore(today)) {
      return '$fieldName cannot be in the past';
    }
    if (mustNotBeFuture && date.isAfter(today)) {
      return '$fieldName cannot be in the future';
    }
    return null;
  }

  /// 10. Kiểm tra Dropdown
  static String? dropdown<T>(T? value, [String fieldName = 'a value']) {
    if (value == null) return 'Please select $fieldName';
    if (value is String && value.trim().isEmpty) return 'Please select $fieldName';
    return null;
  }
}
```

---

## 3. File `lib/utils/dialog_helper.dart` — AlertDialog, SnackBar & DatePicker (Chuẩn Figure 2 Lab 4 & 5)

Trong **Lab 4** và **Lab 5** (Figure 2), đề yêu cầu hiện `AlertDialog` khi:
1. Bỏ trống trường bắt buộc (`Validation` / `Error`: `"Please enter bill name"`).
2. Xác nhận xóa (`Confirm Delete`: `"Are you sure you want to delete ...?"` với 2 nút `CANCEL` và `DELETE`).
3. Thêm / xóa thành công (`Success`: `"Bill added successfully"` / `"Item deleted"`).
Còn **Lab 3** yêu cầu hiện `SnackBar`. File helper dưới đây hỗ trợ cả hai!

```dart
import 'package:flutter/material.dart';

class DialogHelper {
  /// Hiển thị SnackBar (Lab 3)
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        ),
      );
  }

  /// Hiển thị AlertDialog báo lỗi Validation (Figure 2 - Lab 4 & Lab 5)
  static Future<void> showValidationDialog(
    BuildContext context,
    String message, {
    String title = 'Validation', // Lab 4 dùng 'Validation', Lab 5 dùng 'Error'
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị AlertDialog thông báo thành công (Figure 2 - Lab 4 & Lab 5)
  static Future<void> showSuccessDialog(
    BuildContext context,
    String message, {
    String title = 'Success',
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị AlertDialog xác nhận xóa (Lab 3, Lab 4, Lab 5)
  static Future<bool> showConfirmDeleteDialog(
    BuildContext context, {
    String title = 'Confirm Delete',
    required String content,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Mở DatePicker chọn ngày và trả về định dạng ISO 'YYYY-MM-DD' (Lab 4)
  static Future<String?> pickIsoDate(
    BuildContext context, {
    String? currentValue,
  }) async {
    final initialDate = (currentValue != null && currentValue.isNotEmpty)
        ? (DateTime.tryParse(currentValue) ?? DateTime.now())
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return null;

    final yyyy = picked.year.toString().padLeft(4, '0');
    final mm = picked.month.toString().padLeft(2, '0');
    final dd = picked.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }
}
```

---

## 4. Tầng `lib/model/` — 3 Class Model Ngắn Gọn, Bao Phủ Mọi Đề

### 4.1. `lib/model/app_user.dart` (Dành cho Login & Register)
```dart
class AppUser {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String phone;

  AppUser({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'username': username,
        'email': email,
        'password': password,
        'phone': phone,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int?,
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
      );
}
```

### 4.2. `lib/model/category_group.dart` (Bảng cha 1-N: Brand / Category của Lab 3)
```dart
class CategoryGroup {
  final int? id;
  final String name;        // brand_name hoặc category_name
  final String country;     // country (hoặc mô tả)
  final int foundedYear;    // founded_year
  final int totalItems;     // Tính từ SQL LEFT JOIN + COUNT(i.id)

  CategoryGroup({
    this.id,
    required this.name,
    this.country = '',
    this.foundedYear = 2000,
    this.totalItems = 0,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'country': country,
        'founded_year': foundedYear,
      };

  factory CategoryGroup.fromJson(Map<String, dynamic> json) => CategoryGroup(
        id: json['id'] as int?,
        name: json['name'] as String? ?? '',
        country: json['country'] as String? ?? '',
        foundedYear: (json['founded_year'] as num?)?.toInt() ?? 2000,
        totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      );
}
```

### 4.3. `lib/model/item_record.dart` (Bảng chính Generic: Computer / Bill / ShoppingItem)
```dart
class ItemRecord {
  final int? id;
  final String title;        // Lab 3: product_name | Lab 4: bill_name  | Lab 5: itemName
  final String category;     // Lab 3: category_name| Lab 4: category   | Lab 5: category
  final int? groupId;        // Lab 3: brand_id (Foreign Key)
  final String? groupName;   // Lab 3: brand_name (Lấy từ JOIN)
  final String subInfo;      // Lab 3: cpu          | Mở rộng: ghi chú/mô tả
  final double price;        // Lab 3: price        | Lab 4: amount     | Lab 5: price
  final int quantity;        // Lab 3: stock (hoặc RAM)
  final int soldQuantity;    // Lab 3: sold_quantity (hoặc Storage)
  final String status;       // Lab 4: 'Unpaid'/'Paid' | Lab 5: 'Wishlist'/'Purchased'
  final String dueDate;      // Lab 4: 'YYYY-MM-DD'
  final bool isFeatured;     // Lab 3: 0 = False, 1 = True

  ItemRecord({
    this.id,
    required this.title,
    required this.category,
    this.groupId,
    this.groupName,
    this.subInfo = '',
    required this.price,
    this.quantity = 1,
    this.soldQuantity = 0,
    this.status = 'Unpaid', // Đổi thành 'Wishlist' nếu làm Lab 5
    this.dueDate = '',
    this.isFeatured = false,
  });

  // Business Calculations (Tính trực tiếp trong Flutter - Chuẩn Task 4.5 Lab 3)
  double get revenue => price * soldQuantity;
  double get inventoryValue => price * quantity;
  int get totalUnits => quantity + soldQuantity;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'category': category,
        'group_id': groupId,
        'sub_info': subInfo,
        'price': price,
        'quantity': quantity,
        'sold_quantity': soldQuantity,
        'status': status,
        'due_date': dueDate,
        'is_featured': isFeatured ? 1 : 0,
      };

  factory ItemRecord.fromJson(Map<String, dynamic> json) => ItemRecord(
        id: json['id'] as int?,
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        groupId: (json['group_id'] as num?)?.toInt(),
        groupName: json['group_name'] as String?,
        subInfo: json['sub_info'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        soldQuantity: (json['sold_quantity'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? 'Unpaid',
        dueDate: json['due_date'] as String? ?? '',
        isFeatured: ((json['is_featured'] as num?)?.toInt() ?? 0) == 1,
      );
}
```

---

## 5. Tầng `lib/db/database_helper.dart` — Singleton Đa Năng (Chuẩn `sqlite_intro`)

File này giữ nguyên cách viết của `sqlite_intro` (`DatabaseHelper.instance`, `kIsWeb`, `databaseFactoryFfiWeb`) và tích hợp sẵn:
1. **Login / Register** (`loginUser`, `registerUser`, tài khoản mặc định `admin@fpt.edu.vn` / `123456`).
2. **CRUD bảng cha (`groups`)** + `LEFT JOIN` đếm số phần tử con + kiểm tra `COUNT(*)` trước khi xóa.
3. **CRUD bảng chính (`items`)** + `toggleStatus` (`Unpaid ↔ Paid` hoặc `Wishlist ↔ Purchased`) + `queryItemsDynamic` (Search + Filter + Sort) + `getSummaryAndStats` (`SUM`, `COUNT`, `AVG`, `GROUP BY`).

```dart
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../model/app_user.dart';
import '../model/category_group.dart';
import '../model/item_record.dart';

class DatabaseHelper {
  // Đổi tên file DB theo đề bài (VD: 'ComputerStoreDB.db', 'recurring_bills.db', 'shopping_items.db')
  static const _databaseName = 'app_master_database.db';
  static const _userTable = 'users';
  static const _groupTable = 'groups'; // Bảng cha (Brand / Category)
  static const _itemTable = 'items';   // Bảng chính (Computers / Bills / ShoppingItems)

  // Singleton pattern chuẩn sqlite_intro
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return openDatabase(_databaseName, version: 1, onCreate: _onCreate);
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Bảng Users (Cho Login / Register)
    await db.execute('''
      CREATE TABLE $_userTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');

    // 2. Bảng Groups (Bảng cha 1-N như Brands trong Lab 3)
    await db.execute('''
      CREATE TABLE $_groupTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        country TEXT NOT NULL,
        founded_year INTEGER NOT NULL
      )
    ''');

    // 3. Bảng Items (Bảng chính dùng cho Lab 3, Lab 4, Lab 5)
    await db.execute('''
      CREATE TABLE $_itemTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        group_id INTEGER,
        sub_info TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        sold_quantity INTEGER NOT NULL,
        status TEXT NOT NULL,
        due_date TEXT NOT NULL,
        is_featured INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (group_id) REFERENCES $_groupTable (id)
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed 1 tài khoản mặc định để test Login ngay
    await db.insert(_userTable, {
      'username': 'admin',
      'email': 'admin@fpt.edu.vn',
      'password': '123456',
      'phone': '0901234567',
    });

    // Seed 3 Brand/Group mẫu
    final groups = [
      {'name': 'ASUS', 'country': 'Taiwan', 'founded_year': 1989},
      {'name': 'Apple', 'country': 'USA', 'founded_year': 1976},
      {'name': 'Samsung', 'country': 'Korea', 'founded_year': 1938},
    ];
    for (final g in groups) {
      await db.insert(_groupTable, g);
    }

    // Seed dữ liệu mẫu (Nếu đề Lab 4/Lab 5 yêu cầu lần đầu mở app danh sách trống thì comment vòng lặp này lại)
    final sampleItems = [
      {
        'title': 'Electricity - October',
        'category': 'Utilities',
        'group_id': 1,
        'sub_info': 'Monthly Power Bill',
        'price': 850000.0,
        'quantity': 10,
        'sold_quantity': 5,
        'status': 'Unpaid', // Hoặc 'Wishlist'
        'due_date': '2026-10-30',
        'is_featured': 1,
      },
      {
        'title': 'Apartment Rent - November',
        'category': 'Rent',
        'group_id': 2,
        'sub_info': 'Room 402',
        'price': 6500000.0,
        'quantity': 3,
        'sold_quantity': 12,
        'status': 'Unpaid',
        'due_date': '2026-11-05',
        'is_featured': 1,
      },
      {
        'title': 'Internet - Viettel',
        'category': 'Subscription',
        'group_id': 3,
        'sub_info': 'Fiber 150Mbps',
        'price': 250000.0,
        'quantity': 20,
        'sold_quantity': 30,
        'status': 'Paid', // Hoặc 'Purchased'
        'due_date': '2026-11-01',
        'is_featured': 0,
      },
    ];
    for (final item in sampleItems) {
      await db.insert(_itemTable, item);
    }
  }

  // =========================================================================
  // PHẦN 1: AUTHENTICATION (LOGIN & REGISTER)
  // =========================================================================

  Future<AppUser?> login(String emailOrUsername, String password) async {
    final db = await database;
    final maps = await db.query(
      _userTable,
      where: '(LOWER(email) = LOWER(?) OR LOWER(username) = LOWER(?)) AND password = ?',
      whereArgs: [emailOrUsername.trim(), emailOrUsername.trim(), password],
    );
    if (maps.isEmpty) return null;
    return AppUser.fromJson(maps.first);
  }

  Future<bool> isEmailOrUsernameTaken(String email, String username) async {
    final db = await database;
    final maps = await db.query(
      _userTable,
      where: 'LOWER(email) = LOWER(?) OR LOWER(username) = LOWER(?)',
      whereArgs: [email.trim(), username.trim()],
    );
    return maps.isNotEmpty;
  }

  Future<AppUser> register(AppUser user) async {
    final db = await database;
    final id = await db.insert(_userTable, user.toJson());
    return AppUser(
      id: id,
      username: user.username,
      email: user.email,
      password: user.password,
      phone: user.phone,
    );
  }

  // =========================================================================
  // PHẦN 2: QUẢN LÝ BẢNG CHA 1-N (GROUPS / BRANDS / CATEGORIES - LAB 3)
  // =========================================================================

  Future<List<CategoryGroup>> getAllGroups({String? keyword}) async {
    final db = await database;
    String whereSql = '';
    List<Object?> args = [];

    if (keyword != null && keyword.trim().isNotEmpty) {
      final kw = '%${keyword.trim()}%';
      whereSql = 'WHERE g.name LIKE ? COLLATE NOCASE OR g.country LIKE ? COLLATE NOCASE';
      args = [kw, kw];
    }

    final maps = await db.rawQuery('''
      SELECT
        g.id,
        g.name,
        g.country,
        g.founded_year,
        COUNT(i.id) AS totalItems
      FROM $_groupTable g
      LEFT JOIN $_itemTable i ON g.id = i.group_id
      $whereSql
      GROUP BY g.id
      ORDER BY g.name ASC
    ''', args);

    return [for (final m in maps) CategoryGroup.fromJson(m)];
  }

  Future<bool> isGroupNameDuplicate(String name, {int? excludeId}) async {
    final db = await database;
    final maps = await db.query(
      _groupTable,
      where: excludeId != null
          ? 'LOWER(name) = LOWER(?) AND id != ?'
          : 'LOWER(name) = LOWER(?)',
      whereArgs: excludeId != null ? [name.trim(), excludeId] : [name.trim()],
    );
    return maps.isNotEmpty;
  }

  Future<int> insertGroup(CategoryGroup group) async {
    final db = await database;
    return db.insert(_groupTable, group.toJson());
  }

  Future<int> updateGroup(CategoryGroup group) async {
    final db = await database;
    return db.update(_groupTable, group.toJson(), where: 'id = ?', whereArgs: [group.id]);
  }

  /// Kiểm tra bảng cha có đang được tham chiếu bởi bảng con không trước khi xóa (Lab 3 Task 2.4 & 3.4)
  Future<int> countItemsByGroup(int groupId) async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM $_itemTable WHERE group_id = ?',
      [groupId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> deleteGroup(int id) async {
    final db = await database;
    return db.delete(_groupTable, where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // PHẦN 3: QUẢN LÝ BẢNG CHÍNH (ITEMS: COMPUTERS / BILLS / SHOPPING ITEMS)
  // =========================================================================

  /// Kiểm tra trùng tên sản phẩm / hóa đơn (Unique validation)
  Future<bool> isItemTitleDuplicate(String title, {int? excludeId}) async {
    final db = await database;
    final maps = await db.query(
      _itemTable,
      where: excludeId != null
          ? 'LOWER(title) = LOWER(?) AND id != ?'
          : 'LOWER(title) = LOWER(?)',
      whereArgs: excludeId != null ? [title.trim(), excludeId] : [title.trim()],
    );
    return maps.isNotEmpty;
  }

  /// Lấy toàn bộ danh sách kèm LEFT JOIN bảng cha + Hỗ trợ Search, Filter, Sort động
  Future<List<ItemRecord>> getItems({
    String? keyword,
    String? category,
    int? groupId,
    String? status,
    bool? featuredOnly,
    String? sortBy,
  }) async {
    final db = await database;
    final List<String> conditions = [];
    final List<Object?> args = [];

    if (keyword != null && keyword.trim().isNotEmpty) {
      final kw = '%${keyword.trim()}%';
      conditions.add(
        '(i.title LIKE ? COLLATE NOCASE OR i.category LIKE ? COLLATE NOCASE OR i.sub_info LIKE ? COLLATE NOCASE OR g.name LIKE ? COLLATE NOCASE)',
      );
      args.addAll([kw, kw, kw, kw]);
    }

    if (category != null && category.isNotEmpty) {
      conditions.add('i.category = ?');
      args.add(category);
    }

    if (groupId != null) {
      conditions.add('i.group_id = ?');
      args.add(groupId);
    }

    if (status != null && status.isNotEmpty) {
      conditions.add('i.status = ?');
      args.add(status);
    }

    if (featuredOnly == true) {
      conditions.add('i.is_featured = 1');
    }

    final whereSql = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

    String orderSql = 'ORDER BY i.id DESC';
    switch (sortBy) {
      case 'price_asc':
        orderSql = 'ORDER BY i.price ASC';
        break;
      case 'price_desc':
        orderSql = 'ORDER BY i.price DESC';
        break;
      case 'title_asc':
        orderSql = 'ORDER BY i.title ASC';
        break;
      case 'title_desc':
        orderSql = 'ORDER BY i.title DESC';
        break;
    }

    final maps = await db.rawQuery('''
      SELECT
        i.*,
        g.name AS group_name
      FROM $_itemTable i
      LEFT JOIN $_groupTable g ON i.group_id = g.id
      $whereSql
      $orderSql
    ''', args);

    return [for (final map in maps) ItemRecord.fromJson(map)];
  }

  Future<ItemRecord?> getItemById(int id) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT
        i.*,
        g.name AS group_name
      FROM $_itemTable i
      LEFT JOIN $_groupTable g ON i.group_id = g.id
      WHERE i.id = ?
    ''', [id]);
    if (maps.isEmpty) return null;
    return ItemRecord.fromJson(maps.first);
  }

  Future<int> insertItem(ItemRecord item) async {
    final db = await database;
    return db.insert(_itemTable, item.toJson());
  }

  Future<int> updateItem(ItemRecord item) async {
    final db = await database;
    return db.update(
      _itemTable,
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Đổi nhanh trạng thái (Chuẩn Lab 4: 'Unpaid' ↔ 'Paid', Lab 5: 'Wishlist' ↔ 'Purchased')
  Future<int> toggleItemStatus(
    int id,
    String currentStatus, {
    String statusA = 'Unpaid', // Đổi thành 'Wishlist' nếu làm Lab 5
    String statusB = 'Paid',   // Đổi thành 'Purchased' nếu làm Lab 5
  }) async {
    final db = await database;
    final nextStatus = (currentStatus == statusA) ? statusB : statusA;
    return db.update(
      _itemTable,
      {'status': nextStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return db.delete(_itemTable, where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // PHẦN 4: SUMMARY & STATISTICS (LAB 3 TASK 6 + LAB 4 TASK 4 + LAB 5 TASK 4)
  // =========================================================================

  /// Tính tổng tiền theo trạng thái (VD: Tổng tiền hóa đơn 'Unpaid' ở Lab 4, hoặc 'Wishlist' ở Lab 5)
  Future<double> getTotalAmountByStatus(String targetStatus) async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT COALESCE(SUM(price), 0) AS total FROM $_itemTable WHERE status = ?',
      [targetStatus],
    );
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Thống kê tổng hợp bằng SQL Aggregate Functions (Lab 3 Task 6)
  Future<Map<String, dynamic>> getOverallStatistics() async {
    final db = await database;
    final general = await db.rawQuery('''
      SELECT
        COUNT(*) AS totalCount,
        COALESCE(SUM(price), 0) AS sumPrice,
        COALESCE(AVG(price), 0) AS avgPrice,
        COALESCE(SUM(price * sold_quantity), 0) AS totalRevenue,
        COALESCE(SUM(price * quantity), 0) AS totalInventoryValue
      FROM $_itemTable
    ''');

    final byCategory = await db.rawQuery('''
      SELECT
        category,
        COUNT(*) AS itemCount,
        COALESCE(SUM(price), 0) AS totalAmount
      FROM $_itemTable
      GROUP BY category
      ORDER BY totalAmount DESC
    ''');

    final mostExpensive = await db.rawQuery('''
      SELECT title, price FROM $_itemTable ORDER BY price DESC LIMIT 1
    ''');

    return {
      'general': general.first,
      'byCategory': byCategory,
      'mostExpensive': mostExpensive.isEmpty ? null : mostExpensive.first,
    };
  }
}
```

---

## 6. Tầng `lib/providers/app_providers.dart` — Riverpod Notifier Gọn Nhẹ

Viết theo đúng cơ chế `AsyncNotifier` + `ref.invalidateSelf(); await future;` của `sqlite_intro`, nhưng khai báo `AsyncNotifierProvider` trực tiếp để **không cần chạy `build_runner`** mỗi khi sửa code lúc đi thi!

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../model/app_user.dart';
import '../model/category_group.dart';
import '../model/item_record.dart';

// 1. Provider lưu User đang đăng nhập (null = chưa đăng nhập)
class AuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void setUser(AppUser? user) => state = user;
  void logout() => state = null;
}

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

// 2. Provider quản lý danh sách Bảng chính (Items: Computers / Bills / ShoppingItems)
class ItemListNotifier extends AsyncNotifier<List<ItemRecord>> {
  String keyword = '';
  String? selectedCategory;
  int? selectedGroupId;
  String? selectedStatus;
  bool featuredOnly = false;
  String? sortBy;

  @override
  Future<List<ItemRecord>> build() async {
    return DatabaseHelper.instance.getItems(
      keyword: keyword,
      category: selectedCategory,
      groupId: selectedGroupId,
      status: selectedStatus,
      featuredOnly: featuredOnly,
      sortBy: sortBy,
    );
  }

  Future<void> addItem(ItemRecord item) async {
    await DatabaseHelper.instance.insertItem(item);
    ref.invalidate(groupListProvider);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateItem(ItemRecord item) async {
    await DatabaseHelper.instance.updateItem(item);
    ref.invalidate(groupListProvider);
    ref.invalidateSelf();
    await future;
  }

  Future<void> toggleStatus(
    int id,
    String currentStatus, {
    String statusA = 'Unpaid',
    String statusB = 'Paid',
  }) async {
    await DatabaseHelper.instance.toggleItemStatus(
      id,
      currentStatus,
      statusA: statusA,
      statusB: statusB,
    );
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteItem(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
    ref.invalidate(groupListProvider);
    ref.invalidateSelf();
    await future;
  }

  Future<void> search(String kw) async {
    keyword = kw;
    ref.invalidateSelf();
    await future;
  }

  Future<void> applyFilter({
    String? category,
    int? groupId,
    String? status,
    bool? featured,
    String? sort,
  }) async {
    selectedCategory = category;
    selectedGroupId = groupId;
    selectedStatus = status;
    if (featured != null) featuredOnly = featured;
    sortBy = sort;
    ref.invalidateSelf();
    await future;
  }

  Future<void> resetFilters() async {
    keyword = '';
    selectedCategory = null;
    selectedGroupId = null;
    selectedStatus = null;
    featuredOnly = false;
    sortBy = null;
    ref.invalidateSelf();
    await future;
  }
}

final itemListProvider =
    AsyncNotifierProvider<ItemListNotifier, List<ItemRecord>>(ItemListNotifier.new);

// 3. Provider quản lý Bảng cha 1-N (Groups / Brands)
class GroupListNotifier extends AsyncNotifier<List<CategoryGroup>> {
  String keyword = '';

  @override
  Future<List<CategoryGroup>> build() async {
    return DatabaseHelper.instance.getAllGroups(keyword: keyword);
  }

  Future<void> search(String kw) async {
    keyword = kw;
    ref.invalidateSelf();
    await future;
  }

  Future<void> addGroup(CategoryGroup group) async {
    await DatabaseHelper.instance.insertGroup(group);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateGroup(CategoryGroup group) async {
    await DatabaseHelper.instance.updateGroup(group);
    ref.invalidateSelf();
    await future;
  }

  /// Trả về false nếu Group đang có sản phẩm con tham chiếu tới (chặn xóa theo Lab 3)
  Future<bool> deleteGroup(int id) async {
    final count = await DatabaseHelper.instance.countItemsByGroup(id);
    if (count > 0) return false;
    await DatabaseHelper.instance.deleteGroup(id);
    ref.invalidateSelf();
    await future;
    return true;
  }
}

final groupListProvider =
    AsyncNotifierProvider<GroupListNotifier, List<CategoryGroup>>(GroupListNotifier.new);
```

---

## 7. Tầng Giao Diện `lib/ui/` — Đơn Giản, Đầy Đủ 100% Tính Năng

### 7.1. Màn hình Login & Register (`lib/ui/login_screen.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../model/app_user.dart';
import '../providers/app_providers.dart';
import '../utils/app_validators.dart';
import '../utils/dialog_helper.dart';
import 'main_tab_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true;

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isLoginMode) {
      final user = await DatabaseHelper.instance.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (!mounted) return;
      if (user == null) {
        await DialogHelper.showValidationDialog(
          context,
          'Invalid email/username or password! (Hint: admin@fpt.edu.vn / 123456)',
          title: 'Login Failed',
        );
        return;
      }
      ref.read(authProvider.notifier).setUser(user);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
      );
    } else {
      final taken = await DatabaseHelper.instance.isEmailOrUsernameTaken(
        _emailCtrl.text.trim(),
        _usernameCtrl.text.trim(),
      );
      if (!mounted) return;
      if (taken) {
        await DialogHelper.showValidationDialog(
          context,
          'Email or Username already exists!',
        );
        return;
      }

      final newUser = await DatabaseHelper.instance.register(
        AppUser(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          phone: _phoneCtrl.text.trim(),
        ),
      );
      if (!mounted) return;
      await DialogHelper.showSuccessDialog(context, 'Account registered successfully!');
      ref.read(authProvider.notifier).setUser(newUser);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLoginMode ? 'Login' : 'Register Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person, size: 64, color: Colors.indigo),
                const SizedBox(height: 16),
                if (!_isLoginMode) ...[
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => AppValidators.length(v, fieldName: 'Username', min: 3),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: _isLoginMode ? 'Email or Username *' : 'Email *',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => _isLoginMode
                      ? AppValidators.required(v, 'email or username')
                      : AppValidators.email(v),
                ),
                const SizedBox(height: 12),
                if (!_isLoginMode) ...[
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      border: OutlineInputBorder(),
                    ),
                    validator: AppValidators.phone,
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => AppValidators.password(v, minLength: 6),
                ),
                const SizedBox(height: 12),
                if (!_isLoginMode) ...[
                  TextFormField(
                    controller: _confirmPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => AppValidators.confirmPassword(v, _passwordCtrl.text),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isLoginMode ? 'LOGIN' : 'REGISTER'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                  child: Text(
                    _isLoginMode
                        ? "Don't have an account? Register now"
                        : 'Already have an account? Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### 7.2. Màn hình Điều Hướng `BottomNavigationBar` (`lib/ui/main_tab_screen.dart`)
```dart
import 'package:flutter/material.dart';
import 'group_manage_screen.dart';
import 'home_list_screen.dart';
import 'summary_stats_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const HomeListScreen(),     // Tab 1: Home (Danh sách + Banner + Search/Filter + FAB)
      const SummaryStatsScreen(), // Tab 2: Summary (Lab 4 Unpaid / Lab 5 Wishlist) & Stats (Lab 3)
      const GroupManageScreen(),  // Tab 3: Quản lý bảng cha 1-N (Brands / Categories - Lab 3)
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Summary & Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Groups (1-N)'),
        ],
      ),
    );
  }
}
```

---

### 7.3. Màn hình Chính `HomeListScreen` (`lib/ui/home_list_screen.dart`)
Bao gồm đầy đủ yêu cầu của cả 3 Lab:
- `AppBar` (kèm nút Logout về `LoginScreen`).
- `Banner` đầu trang bằng `Image.asset('assets/images/banner.png')` kèm `errorBuilder` tự vẽ banner đẹp mắt nếu chưa có file ảnh.
- Thanh `Search` real-time + `Dropdown` lọc nhanh theo `Category` / `Status` + `Sort` + `Reset`.
- `ListView.builder` + `RefreshIndicator` + giao diện **Empty State** khi chưa có dữ liệu (Chuẩn Figure 1 Lab 4 & Lab 5).
- `FloatingActionButton` (`+`) mở màn hình Thêm mới (`ItemFormScreen`).
- Bấm vào 1 dòng mở `ItemDetailScreen` (hoặc mở thẳng `ItemFormScreen(existingItem: item)` nếu đề giống Lab 4).

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import 'item_detail_screen.dart';
import 'item_form_screen.dart';
import 'login_screen.dart';

class HomeListScreen extends ConsumerStatefulWidget {
  const HomeListScreen({super.key});

  @override
  ConsumerState<HomeListScreen> createState() => _HomeListScreenState();
}

class _HomeListScreenState extends ConsumerState<HomeListScreen> {
  final _searchCtrl = TextEditingController();

  // Danh sách Category cố định (Dùng cho Lab 4, Lab 5; dễ dàng sửa lại theo đề)
  static const List<String> categories = [
    'Utilities',
    'Subscription',
    'Rent',
    'Finance',
    'Health',
    'Fashion',
    'Electronics',
    'Laptop',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemListProvider);
    final notifier = ref.read(itemListProvider.notifier);
    final currentUser = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentUser != null
              ? 'Manager (${currentUser.username})'
              : 'Management System',
        ),
        actions: [
          IconButton(
            tooltip: 'Reset Filters',
            icon: const Icon(Icons.filter_alt_off),
            onPressed: () {
              _searchCtrl.clear();
              notifier.resetFilters();
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Promotional Banner (Yêu cầu chung của Lab 3, Lab 4, Lab 5)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 90,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/banner.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.indigo.shade700,
                    padding: const EdgeInsets.all(16),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amber, size: 40),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SMART MANAGEMENT APP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Manage Bills, Shopping Wishlist & Store Inventory',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Search Bar (Real-time search - Lab 3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search by Name, Category, Brand...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: notifier.search,
            ),
          ),

          // 3. Filter & Sort Bar (Lab 3 Task 5)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: notifier.selectedCategory,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...categories.map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      ),
                    ],
                    onChanged: (val) => notifier.applyFilter(
                      category: val,
                      status: notifier.selectedStatus,
                      sort: notifier.sortBy,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: notifier.sortBy,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Default')),
                      DropdownMenuItem(value: 'price_asc', child: Text('Price ↑')),
                      DropdownMenuItem(value: 'price_desc', child: Text('Price ↓')),
                      DropdownMenuItem(value: 'title_asc', child: Text('Name A-Z')),
                      DropdownMenuItem(value: 'title_desc', child: Text('Name Z-A')),
                    ],
                    onChanged: (val) => notifier.applyFilter(
                      category: notifier.selectedCategory,
                      status: notifier.selectedStatus,
                      sort: val,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Danh sách chính (ListView.builder + Empty State + Pull-to-Refresh)
          Expanded(
            child: itemsAsync.when(
              data: (items) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(itemListProvider);
                  await ref.read(itemListProvider.future);
                },
                child: items.isEmpty
                    // Empty State chuẩn Figure 1 của Lab 4 & Lab 5
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Center(
                            child: Text(
                              'No items yet!\nPress "+" button to add a new item.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isPositiveStatus =
                              item.status == 'Paid' || item.status == 'Purchased';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            child: ListTile(
                              onTap: () {
                                // Điều hướng sang Detail Screen (Lab 3, Lab 5)
                                // Nếu đề yêu cầu bấm vào mở thẳng Update Screen (như Lab 4),
                                // chỉ cần đổi ItemDetailScreen thành ItemFormScreen(existingItem: item)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetailScreen(itemId: item.id!),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade50,
                                child: Icon(
                                  item.isFeatured ? Icons.star : Icons.receipt_long,
                                  color: item.isFeatured ? Colors.amber.shade700 : Colors.indigo,
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category: ${item.category}'
                                    '${item.groupName != null ? ' • Brand: ${item.groupName}' : ''}',
                                  ),
                                  if (item.dueDate.isNotEmpty)
                                    Text('Due Date: ${item.dueDate}'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${item.price.toStringAsFixed(0)} đ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPositiveStatus
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isPositiveStatus
                                            ? Colors.green.shade800
                                            : Colors.orange.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ItemFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

### 7.4. Màn hình Thêm / Sửa `ItemFormScreen` (`lib/ui/item_form_screen.dart`)
Hội tụ đầy đủ mọi Widget nhập liệu của cả 3 bài Lab:
- `TextFormField` cho Tên, Ghi chú/CPU, Giá (`price`/`amount`), Số lượng (`quantity`/`stock`), Đã bán (`soldQuantity`).
- `DropdownButtonFormField` cho `Category` và `Brand/Group` (tải từ SQLite).
- `TextFormField` kết hợp `DialogHelper.pickIsoDate` mở `DatePicker` chọn ngày `YYYY-MM-DD` (Chuẩn Lab 4).
- `DropdownButtonFormField` cho `Status` (mặc định `'Unpaid'` như Lab 4 hoặc `'Wishlist'` như Lab 5).
- `SwitchListTile` cho `isFeatured` (Chuẩn Lab 3).
- **Hàng 3 nút trên cùng 1 `Row`** khi ở chế độ Update (`Update`, `Delete`, `Back`) đúng chuẩn yêu cầu 3 của Lab 4!

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../model/item_record.dart';
import '../providers/app_providers.dart';
import '../utils/app_validators.dart';
import '../utils/dialog_helper.dart';
import 'home_list_screen.dart';

class ItemFormScreen extends ConsumerStatefulWidget {
  final ItemRecord? existingItem;

  const ItemFormScreen({super.key, this.existingItem});

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _subInfoCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _soldCtrl;
  late final TextEditingController _dueDateCtrl;

  String _selectedCategory = HomeListScreenStateCategories.defaultCategory;
  int? _selectedGroupId;
  String _selectedStatus = 'Unpaid'; // Mặc định 'Unpaid' (Lab 4) hoặc 'Wishlist' (Lab 5)
  bool _isFeatured = false;

  // Cấu hình danh sách trạng thái (Bao gồm cả Lab 4 và Lab 5)
  static const List<String> statusOptions = ['Unpaid', 'Paid', 'Wishlist', 'Purchased'];

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _titleCtrl = TextEditingController(text: item?.title ?? '');
    _subInfoCtrl = TextEditingController(text: item?.subInfo ?? 'Standard');
    _priceCtrl = TextEditingController(
      text: item != null ? item.price.toStringAsFixed(0) : '',
    );
    _qtyCtrl = TextEditingController(text: (item?.quantity ?? 10).toString());
    _soldCtrl = TextEditingController(text: (item?.soldQuantity ?? 0).toString());

    final todayIso = DateTime.now().toIso8601String().split('T').first;
    _dueDateCtrl = TextEditingController(text: item?.dueDate ?? todayIso);

    if (item != null && HomeListScreenStateCategories.list.contains(item.category)) {
      _selectedCategory = item.category;
    }
    _selectedGroupId = item?.groupId;
    if (item != null && statusOptions.contains(item.status)) {
      _selectedStatus = item.status;
    }
    _isFeatured = item?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subInfoCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _soldCtrl.dispose();
    _dueDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    // Nếu bỏ trống tên, hiện thêm AlertDialog chuẩn Figure 2 của Lab 4 & Lab 5
    if (_titleCtrl.text.trim().isEmpty) {
      await DialogHelper.showValidationDialog(context, 'Please enter item/bill name');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra trùng tên trong SQLite (Chuẩn Lab 3)
    final isDup = await DatabaseHelper.instance.isItemTitleDuplicate(
      _titleCtrl.text.trim(),
      excludeId: widget.existingItem?.id,
    );
    if (!mounted) return;
    if (isDup) {
      await DialogHelper.showValidationDialog(
        context,
        'This name already exists. Duplicate name is not allowed!',
      );
      return;
    }

    final record = ItemRecord(
      id: widget.existingItem?.id,
      title: _titleCtrl.text.trim(),
      category: _selectedCategory,
      groupId: _selectedGroupId,
      subInfo: _subInfoCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      quantity: int.parse(_qtyCtrl.text.trim()),
      soldQuantity: int.parse(_soldCtrl.text.trim()),
      status: _selectedStatus,
      dueDate: _dueDateCtrl.text.trim(),
      isFeatured: _isFeatured,
    );

    final isEditing = widget.existingItem != null;
    if (!isEditing) {
      await ref.read(itemListProvider.notifier).addItem(record);
      if (!mounted) return;
      await DialogHelper.showSuccessDialog(context, 'Item added successfully');
      if (mounted) Navigator.pop(context, true);
    } else {
      await ref.read(itemListProvider.notifier).updateItem(record);
      if (!mounted) return;
      await DialogHelper.showSuccessDialog(context, 'Item updated successfully');
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _deleteCurrentItem() async {
    final item = widget.existingItem;
    if (item == null) return;

    final confirmed = await DialogHelper.showConfirmDeleteDialog(
      context,
      content: 'Are you sure you want to delete "${item.title}"?',
    );
    if (!confirmed || !mounted) return;

    await ref.read(itemListProvider.notifier).deleteItem(item.id!);
    if (!mounted) return;
    await DialogHelper.showSuccessDialog(context, 'Item deleted');
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;
    final groupsAsync = ref.watch(groupListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Update Item' : 'Add New Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Tên (Product Name / Bill Name / Item Name)
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Item / Bill Name *',
                  hintText: 'e.g. Electricity - October / Nike Air Force 1',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => AppValidators.required(v, 'name'),
              ),
              const SizedBox(height: 12),

              // 2. Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: HomeListScreenStateCategories.list
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 12),

              // 3. Brand / Group Dropdown lấy từ SQLite (Lab 3)
              groupsAsync.when(
                data: (groups) => DropdownButtonFormField<int?>(
                  value: groups.any((g) => g.id == _selectedGroupId)
                      ? _selectedGroupId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Brand / Group (SQLite FK)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('None')),
                    ...groups.map(
                      (g) => DropdownMenuItem<int?>(value: g.id, child: Text(g.name)),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedGroupId = val),
                ),
                error: (_, __) => const SizedBox.shrink(),
                loading: () => const LinearProgressIndicator(),
              ),
              const SizedBox(height: 12),

              // 4. Price / Amount (VND / USD)
              TextFormField(
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price / Amount *',
                  hintText: 'e.g. 850000',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => AppValidators.doubleNumber(
                  v,
                  fieldName: 'Price / Amount',
                  strictlyPositive: true,
                ),
              ),
              const SizedBox(height: 12),

              // 5. Due Date (YYYY-MM-DD) có DatePicker (Lab 4)
              TextFormField(
                controller: _dueDateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Due Date (YYYY-MM-DD) *',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final picked = await DialogHelper.pickIsoDate(
                    context,
                    currentValue: _dueDateCtrl.text,
                  );
                  if (picked != null) {
                    setState(() => _dueDateCtrl.text = picked);
                  }
                },
                validator: (v) => AppValidators.isoDate(v, fieldName: 'Due Date'),
              ),
              const SizedBox(height: 12),

              // 6. Status Dropdown (Lab 4: Unpaid/Paid, Lab 5: Wishlist/Purchased)
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                ),
                items: statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              const SizedBox(height: 12),

              // 7. Các trường mở rộng của Lab 3 (Stock, Sold Quantity, CPU/SubInfo, Featured Switch)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock / Qty *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => AppValidators.intNumber(
                        v,
                        fieldName: 'Stock',
                        min: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _soldCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sold Qty *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => AppValidators.intNumber(
                        v,
                        fieldName: 'Sold Quantity',
                        min: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _subInfoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Spec / CPU / Note *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => AppValidators.required(v, 'specification'),
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Featured Item'),
                value: _isFeatured,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
              const SizedBox(height: 16),

              // 8. Hàng nút bấm:
              // - Khi Add: 2 nút (Save & Back/Cancel) chuẩn Figure 3 Lab 4 & Lab 5
              // - Khi Edit: 3 nút trên cùng 1 hàng (Update, Delete, Back) chuẩn Figure 4 Lab 4
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _saveForm,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(isEditing ? 'Update' : 'Save'),
                    ),
                  ),
                  if (isEditing) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _deleteCurrentItem,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeListScreenStateCategories {
  static const List<String> list = [
    'Utilities',
    'Subscription',
    'Rent',
    'Finance',
    'Health',
    'Fashion',
    'Electronics',
    'Laptop',
  ];
  static const String defaultCategory = 'Utilities';
}
```

---

### 7.5. Màn hình Chi Tiết `ItemDetailScreen` (`lib/ui/item_detail_screen.dart` — Chuẩn Lab 3 Task 4.5 & Lab 5 Task 3)
- Hiển thị toàn bộ các trường của Item.
- Hiển thị **Business Calculations** (`Revenue`, `Inventory Value`, `Total Units` - Lab 3).
- Có **hàng 3 nút trên cùng 1 dòng** đúng theo Figure 4 của Lab 5:
  1. **Toggle Status** (Đổi giữa `'Unpaid' ↔ 'Paid'` hoặc `'Wishlist' ↔ 'Purchased'`).
  2. **Delete** (Xác nhận xóa bằng `AlertDialog` và quay về Home).
  3. **Back** (Quay về Home).
- Có thêm nút **Edit** trên `AppBar` để mở `ItemFormScreen(existingItem: item)`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../model/item_record.dart';
import '../providers/app_providers.dart';
import '../utils/dialog_helper.dart';
import 'item_form_screen.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final int itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  Future<ItemRecord?>? _detailFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _detailFuture = DatabaseHelper.instance.getItemById(widget.itemId);
    });
  }

  Future<void> _handleToggleStatus(ItemRecord item) async {
    // Tự động nhận diện cặp trạng thái Lab 4 ('Unpaid'/'Paid') hoặc Lab 5 ('Wishlist'/'Purchased')
    final isShoppingMode = item.status == 'Wishlist' || item.status == 'Purchased';
    final statusA = isShoppingMode ? 'Wishlist' : 'Unpaid';
    final statusB = isShoppingMode ? 'Purchased' : 'Paid';

    await ref.read(itemListProvider.notifier).toggleStatus(
          item.id!,
          item.status,
          statusA: statusA,
          statusB: statusB,
        );
    _reload();
    if (!mounted) return;
    DialogHelper.showSnackBar(context, 'Status toggled successfully!');
  }

  Future<void> _handleDelete(ItemRecord item) async {
    final confirmed = await DialogHelper.showConfirmDeleteDialog(
      context,
      content: 'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
    );
    if (!confirmed || !mounted) return;

    await ref.read(itemListProvider.notifier).deleteItem(item.id!);
    if (!mounted) return;
    await DialogHelper.showSuccessDialog(context, 'Item deleted');
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ItemRecord?>(
      future: _detailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final item = snapshot.data;
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail')),
            body: const Center(child: Text('Item not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Information'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemFormScreen(existingItem: item),
                    ),
                  );
                  if (changed == true && mounted) {
                    _reload();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Information',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        _infoRow('ID', '#${item.id}'),
                        _infoRow('Name', item.title),
                        _infoRow('Category', item.category),
                        if (item.groupName != null) _infoRow('Brand / Group', item.groupName!),
                        _infoRow('Spec / Note', item.subInfo),
                        _infoRow('Price / Amount', '${item.price.toStringAsFixed(0)} đ'),
                        _infoRow('Due Date', item.dueDate),
                        _infoRow('Status', item.status),
                        _infoRow('Stock / Qty', '${item.quantity}'),
                        _infoRow('Sold Quantity', '${item.soldQuantity}'),
                        _infoRow('Featured', item.isFeatured ? 'Yes (★)' : 'No'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Business Calculations (Lab 3 Task 4.5)
                Card(
                  color: Colors.indigo.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business Calculations (In-App)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        _infoRow('Revenue (Price × Sold)', '${item.revenue.toStringAsFixed(0)} đ'),
                        _infoRow(
                          'Inventory Value (Price × Stock)',
                          '${item.inventoryValue.toStringAsFixed(0)} đ',
                        ),
                        _infoRow('Total Units (Stock + Sold)', '${item.totalUnits}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Hàng 3 nút trên cùng 1 Row (Chuẩn Figure 4 Lab 5: Toggle Status | Delete | Back)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _handleToggleStatus(item),
                        icon: const Icon(Icons.sync_alt),
                        label: const Text('Toggle Status', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _handleDelete(item),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

---

### 7.6. Màn hình Summary & Statistics (`lib/ui/summary_stats_screen.dart` — Gộp Lab 3 Task 6 + Lab 4 Figure 5 + Lab 5 Figure 5)
Màn hình này giải quyết trọn vẹn:
- **Phần trên**: Chọn trạng thái cần tổng hợp (`'Unpaid'` cho Lab 4 hoặc `'Wishlist'` cho Lab 5), hiển thị `ListView` các mục thuộc trạng thái đó và thẻ **Outstanding / Wishlist Summary** tính tổng số lượng + **Tổng tiền (`SUM`)** ở dưới.
- **Phần dưới**: Thống kê tổng hợp toàn cửa hàng (`Total Items`, `Total Revenue`, `Average Price`, `Most Expensive`, và `Group By Category`) theo đúng chuẩn Task 6 của Lab 3.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../providers/app_providers.dart';

class SummaryStatsScreen extends ConsumerStatefulWidget {
  const SummaryStatsScreen({super.key});

  @override
  ConsumerState<SummaryStatsScreen> createState() => _SummaryStatsScreenState();
}

class _SummaryStatsScreenState extends ConsumerState<SummaryStatsScreen> {
  // Đổi mặc định thành 'Wishlist' nếu làm Lab 5, hoặc 'Unpaid' nếu làm Lab 4
  String _targetStatus = 'Unpaid';

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Summary & Statistics')),
      body: itemsAsync.when(
        data: (allItems) {
          final filteredItems =
              allItems.where((i) => i.status == _targetStatus).toList();
          final totalFilteredCost = filteredItems.fold<double>(
            0.0,
            (sum, item) => sum + item.price,
          );

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Chuyển nhanh giữa Unpaid (Lab 4) và Wishlist (Lab 5)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_targetStatus Summary',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _targetStatus,
                    items: const [
                      DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid (Lab 4)')),
                      DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                      DropdownMenuItem(value: 'Wishlist', child: Text('Wishlist (Lab 5)')),
                      DropdownMenuItem(value: 'Purchased', child: Text('Purchased')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _targetStatus = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Danh sách các mục thuộc trạng thái đang chọn (Figure 5 Lab 4 & Lab 5)
              if (filteredItems.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No items in this status.')),
                  ),
                )
              else
                ...filteredItems.map(
                  (item) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.monetization_on, color: Colors.orange),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.category),
                      trailing: Text(
                        '${item.price.toStringAsFixed(0)} đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ),
                ),

              // Thẻ Tổng kết ở đáy danh sách (Total Outstanding / Total Estimate - Figure 5 Lab 4 & 5)
              Card(
                color: Colors.amber.shade50,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_targetStatus Summary Total',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Number of $_targetStatus items:'),
                          Text(
                            '${filteredItems.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Estimated / Outstanding Cost:'),
                          Text(
                            '${totalFilteredCost.toStringAsFixed(0)} đ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 28),

              // Thống kê SQLite Aggregate (Chuẩn Lab 3 Task 6)
              const Text(
                'SQLite Aggregate Statistics (Lab 3)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<Map<String, dynamic>>(
                future: DatabaseHelper.instance.getOverallStatistics(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final general = snap.data!['general'] as Map<String, dynamic>;
                  final byCategory =
                      snap.data!['byCategory'] as List<Map<String, dynamic>>;
                  final mostExp = snap.data!['mostExpensive'] as Map<String, dynamic>?;

                  return Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              _statLine('Total Products / Items', '${general['totalCount']}'),
                              _statLine(
                                'Average Price',
                                '${(general['avgPrice'] as num).toStringAsFixed(0)} đ',
                              ),
                              _statLine(
                                'Total Revenue (Price × Sold)',
                                '${(general['totalRevenue'] as num).toStringAsFixed(0)} đ',
                              ),
                              _statLine(
                                'Total Inventory (Price × Stock)',
                                '${(general['totalInventoryValue'] as num).toStringAsFixed(0)} đ',
                              ),
                              if (mostExp != null)
                                _statLine(
                                  'Most Expensive',
                                  '${mostExp['title']} (${(mostExp['price'] as num).toStringAsFixed(0)} đ)',
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...byCategory.map(
                        (cat) => Card(
                          child: ListTile(
                            title: Text(
                              'Category: ${cat['category']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Items: ${cat['itemCount']}'),
                            trailing: Text(
                              '${(cat['totalAmount'] as num).toStringAsFixed(0)} đ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _statLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

---

### 7.7. Màn hình Quản Lý Bảng Cha 1-N `GroupManageScreen` (`lib/ui/group_manage_screen.dart` — Chuẩn Lab 3 Task 2 & Task 3)
- Hiển thị danh sách `Brand` / `Category` kèm số sản phẩm con tính từ `LEFT JOIN` (`Products: <totalItems>`).
- Thêm / Sửa với kiểm tra trùng tên và kiểm tra `Founded Year > 1900`.
- Xóa có kiểm tra khóa ngoại: nếu `count > 0` thì chặn xóa và báo lỗi `"This group cannot be deleted because it is currently used by one or more products."`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../model/category_group.dart';
import '../providers/app_providers.dart';
import '../utils/app_validators.dart';
import '../utils/dialog_helper.dart';

class GroupManageScreen extends ConsumerStatefulWidget {
  const GroupManageScreen({super.key});

  @override
  ConsumerState<GroupManageScreen> createState() => _GroupManageScreenState();
}

class _GroupManageScreenState extends ConsumerState<GroupManageScreen> {
  Future<void> _openGroupDialog({CategoryGroup? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final countryCtrl = TextEditingController(text: existing?.country ?? '');
    final yearCtrl = TextEditingController(
      text: existing != null ? existing.foundedYear.toString() : '2000',
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Brand / Group' : 'Edit Brand / Group'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (v) => AppValidators.required(v, 'Name'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: countryCtrl,
                  decoration: const InputDecoration(labelText: 'Country *'),
                  validator: (v) => AppValidators.required(v, 'Country'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: yearCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Founded Year (> 1900) *'),
                  validator: (v) => AppValidators.intNumber(
                    v,
                    fieldName: 'Founded Year',
                    greaterThan: 1900,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final isDup = await DatabaseHelper.instance.isGroupNameDuplicate(
                nameCtrl.text.trim(),
                excludeId: existing?.id,
              );
              if (isDup) {
                if (context.mounted) {
                  await DialogHelper.showValidationDialog(
                    context,
                    'Duplicate Name is not allowed.',
                  );
                }
                return;
              }

              final group = CategoryGroup(
                id: existing?.id,
                name: nameCtrl.text.trim(),
                country: countryCtrl.text.trim(),
                foundedYear: int.parse(yearCtrl.text.trim()),
              );

              if (existing == null) {
                await ref.read(groupListProvider.notifier).addGroup(group);
              } else {
                await ref.read(groupListProvider.notifier).updateGroup(group);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Brands / Groups (1-N)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by Name or Country...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(groupListProvider.notifier).search(v),
            ),
          ),
          Expanded(
            child: groupsAsync.when(
              data: (groups) => ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final g = groups[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: ListTile(
                      title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Country: ${g.country} | Founded: ${g.foundedYear}\n'
                        'Linked Items: ${g.totalItems}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _openGroupDialog(existing: g),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final ok = await DialogHelper.showConfirmDeleteDialog(
                                context,
                                content: 'Are you sure you want to delete "${g.name}"?',
                              );
                              if (!ok || !context.mounted) return;
                              final deleted = await ref
                                  .read(groupListProvider.notifier)
                                  .deleteGroup(g.id!);
                              if (!context.mounted) return;
                              if (!deleted) {
                                DialogHelper.showSnackBar(
                                  context,
                                  'Cannot delete because it is currently used by one or more items.',
                                  isError: true,
                                );
                              } else {
                                DialogHelper.showSnackBar(context, 'Deleted successfully.');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openGroupDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

### 7.8. File `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/login_screen.dart';
import 'ui/main_tab_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Đổi thành false nếu đề không yêu cầu màn hình Login lúc khởi động
  static const bool requireLogin = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite Master Resource',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: requireLogin ? const LoginScreen() : const MainTabScreen(),
    );
  }
}
```

---

## 8. Bảng Cheat Sheet Tùy Biến Nhanh Trong 3 Phút Khi Vào Phòng Thi

Khi nhận đề mới (ví dụ: Quản lý Sách, Quản lý Nhân viên, Quản lý Khóa học, Quản lý Hóa đơn...), bạn chỉ cần sửa đúng **4 vị trí** sau:

1. **Bật / Tắt Login (`lib/main.dart`)**:
   - Đề có yêu cầu Login/Register: để `requireLogin = true`.
   - Đề vào thẳng Home (như Lab 3, 4, 5): đổi `requireLogin = false`.
2. **Đổi tên Database & Bảng (`lib/db/database_helper.dart`)**:
   - Đổi `_databaseName = 'TenDBTheoDe.db'`.
   - Nếu đề yêu cầu lần đầu mở app danh sách trống (như Lab 4, Lab 5): comment dòng `await db.insert(_itemTable, item);` trong `_seedInitialData`.
3. **Đổi cặp trạng thái (`status`) & Danh mục (`categories`)**:
   - Nếu đề kiểu **Lab 4 (Hóa đơn)**: `status` mặc định là `'Unpaid'`, cặp toggle là `'Unpaid' ↔ 'Paid'`.
   - Nếu đề kiểu **Lab 5 (Giỏ hàng / Yêu thích)**: `status` mặc định là `'Wishlist'`, cặp toggle là `'Wishlist' ↔ 'Purchased'`.
   - Nếu đề kiểu **Quản lý Công việc / Task**: đổi thành `'Pending' ↔ 'Completed'`.
4. **Chọn luồng bấm vào 1 Item trên `HomeListScreen`**:
   - Nếu đề có **Detail Screen riêng** (như Lab 3, Lab 5): giữ nguyên `Navigator.push(..., ItemDetailScreen(itemId: item.id!))`.
   - Nếu đề yêu cầu **bấm vào Item mở thẳng màn hình Update** (như Lab 4): đổi thành `Navigator.push(..., ItemFormScreen(existingItem: item))`.
