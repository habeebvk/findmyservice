import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../model/user_request.dart';
import '../model/job.dart';
import '../model/user_model.dart';
import '../model/review_model.dart';
import '../model/notification_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static final Map<String, Database> _databases = {};

  final List<String> workerRoles = [
    'plumber',
    'electrician',
    'carpenter',
    'painter',
    'welder',
    'cleaner',
    'mechanic',
    'pest_care',
    'gardening',
    'glass_repair',
    'taxi',
  ];

  String normalizeRole(String? role) {
    if (role == null) return 'main';
    String normalized = role.toLowerCase().replaceAll(' ', '_');
    if (normalized == 'electricals' || normalized == 'electrician')
      return 'electrician';
    if (normalized == 'carpentry' || normalized == 'carpenter')
      return 'carpenter';
    if (normalized == 'plumbing' || normalized == 'plumber') return 'plumber';
    if (normalized == 'painting' || normalized == 'painter') return 'painter';
    if (normalized == 'cleaning' || normalized == 'cleaner') return 'cleaner';
    if (normalized == 'pest_care' || normalized == 'pest_control')
      return 'pest_care';
    if (normalized == 'glass_repair' || normalized == 'glass_shine')
      return 'glass_repair';
    if (normalized == 'gardening') return 'gardening';
    if (normalized == 'goods_taxi' ||
        normalized == 'taxi' ||
        normalized == 'taxi_booking')
      return 'taxi';
    if (normalized.contains('plumb')) return 'plumber';
    if (normalized.contains('electri')) return 'electrician';
    if (normalized.contains('carpen')) return 'carpenter';
    if (normalized.contains('clean')) return 'cleaner';
    if (normalized.contains('paint')) return 'painter';
    if (normalized.contains('mechanic')) return 'mechanic';
    if (normalized.contains('welder') || normalized.contains('welding'))
      return 'welder';
    if (normalized.contains('taxi')) return 'taxi';

    if (workerRoles.contains(normalized)) return normalized;
    return 'main';
  }

  Future<Database> getDatabase(String? role) async {
    String roleName = normalizeRole(role?.trim());
    if (_databases.containsKey(roleName)) return _databases[roleName]!;

    String fileName = roleName == 'main' ? 'main_users.db' : '$roleName.db';
    String path = join(await getDatabasesPath(), fileName);

    Database db = await openDatabase(
      path,
      version: 10,
      onCreate: (db, version) async {
        if (roleName == 'main') {
          await _onCreateMain(db);
        } else {
          await _onCreateRole(db);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          if (roleName != 'main') {
            try {
              await db.execute(
                'ALTER TABLE bookings ADD COLUMN customerName TEXT',
              );
            } catch (e) {
              // Column might already exist if recreations happened
              print("Migration Note: $e");
            }
          }
        }
        if (oldVersion < 3) {
          if (roleName != 'main') {
            try {
              await db.execute('''
                CREATE TABLE reviews(
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  workerName TEXT NOT NULL,
                  customerName TEXT NOT NULL,
                  rating REAL NOT NULL,
                  comment TEXT,
                  date TEXT NOT NULL
                )
              ''');
              debugPrint("✅ Migration v3: Created reviews table for $roleName");
            } catch (e) {
              // Table might already exist
              debugPrint("⚠️ Migration v3 Note: $e");
            }
          }
        }
        if (oldVersion < 5) {
          if (roleName == 'main') {
            try {
              // Create centralized reviews table if missing (v3 migration for main)
              await db.execute('''
                CREATE TABLE IF NOT EXISTS reviews(
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  workerName TEXT NOT NULL,
                  customerName TEXT NOT NULL,
                  rating REAL NOT NULL,
                  comment TEXT,
                  date TEXT NOT NULL,
                  role TEXT NOT NULL
                )
              ''');

              // Create notifications table if missing
              await db.execute('''
                CREATE TABLE IF NOT EXISTS notifications(
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  title TEXT NOT NULL,
                  message TEXT NOT NULL,
                  date TEXT NOT NULL,
                  type TEXT NOT NULL,
                  recipientName TEXT NOT NULL,
                  isRead INTEGER DEFAULT 0
                )
              ''');
            } catch (e) {
              debugPrint("⚠️ Migration v5 Note: $e");
            }
          }
        }
        if (oldVersion < 7) {
          if (roleName == 'main') {
            try {
              await db.execute(
                'ALTER TABLE users ADD COLUMN isApproved INTEGER DEFAULT 1',
              );
              debugPrint("✅ Migration v7: Added isApproved column to users");
            } catch (e) {
              debugPrint("⚠️ Migration v7 Note: $e");
            }
          }
        }
        if (oldVersion < 8) {
          if (roleName == 'main') {
            try {
              await db.execute('ALTER TABLE users ADD COLUMN experience TEXT');
              debugPrint("✅ Migration v8: Added experience column to users");
            } catch (e) {
              debugPrint("⚠️ Migration v8 Note: $e");
            }
          }
        }
        if (oldVersion < 9) {
          if (roleName != 'main') {
            try {
              await db.execute(
                "ALTER TABLE bookings ADD COLUMN paymentStatus TEXT DEFAULT 'unpaid'",
              );
              await db.execute(
                "ALTER TABLE bookings ADD COLUMN transactionId TEXT",
              );
              debugPrint(
                "✅ Migration v9: Added payment columns to bookings for $roleName",
              );
            } catch (e) {
              debugPrint("⚠️ Migration v9 Note: $e");
            }
          }
        }
        if (oldVersion < 10) {
          if (roleName == 'main') {
            try {
              await db.execute('ALTER TABLE users ADD COLUMN description TEXT');
              debugPrint("✅ Migration v10: Added description column to users");
            } catch (e) {
              debugPrint("⚠️ Migration v10 Note: $e");
            }
          }
        }
      },
    );

    _databases[roleName] = db;
    return db;
  }

  Future<void> _onCreateMain(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        role TEXT,
        workType TEXT,
        profilePic TEXT,
        phone TEXT,
        location TEXT,
        salary TEXT,
        experience TEXT,
        description TEXT,
        isApproved INTEGER DEFAULT 1
      )
    ''');

    // Centralized reviews table
    await db.execute('''
      CREATE TABLE reviews(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workerName TEXT NOT NULL,
        customerName TEXT NOT NULL,
        rating REAL NOT NULL,
        comment TEXT,
        date TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        recipientName TEXT NOT NULL,
        isRead INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onCreateRole(Database db) async {
    await db.execute('''
      CREATE TABLE bookings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        service TEXT,
        workerName TEXT,
        customerName TEXT,
        requestDate TEXT,
        status TEXT,
        price INTEGER,
        description TEXT,
        paymentStatus TEXT DEFAULT 'unpaid',
        transactionId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE jobs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        category TEXT,
        description TEXT,
        price INTEGER,
        providerName TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workerName TEXT NOT NULL,
        customerName TEXT NOT NULL,
        rating REAL NOT NULL,
        comment TEXT,
        date TEXT NOT NULL
      )
    ''');
  }

  // Auth CRUD (Always Main)
  Future<int> insertUser(UserModel user) async {
    Database db = await getDatabase('main');
    try {
      int result = await db.insert('users', user.toMap());
      debugPrint("✅ User inserted successfully into main: ${user.email}");
      return result;
    } catch (e) {
      debugPrint("❌ Error inserting user into main: $e");
      return -1;
    }
  }

  Future<int> updateUserApprovalStatus(int userId, int status) async {
    Database db = await getDatabase('main');
    try {
      return await db.update(
        'users',
        {'isApproved': status},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      debugPrint("❌ Error updating user approval status: $e");
      return -1;
    }
  }

  Future<int> updateUser(UserModel user) async {
    Database db = await getDatabase('main');
    try {
      return await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      debugPrint("❌ Error updating user: $e");
      return -1;
    }
  }

  Future<UserModel?> validateUser(String email, String password) async {
    Database db = await getDatabase('main');
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteUser(int userId) async {
    Database db = await getDatabase('main');
    try {
      return await db.delete('users', where: 'id = ?', whereArgs: [userId]);
    } catch (e) {
      debugPrint("❌ Error deleting user: $e");
      return -1;
    }
  }

  Future<bool> userExists(String email) async {
    Database db = await getDatabase('main');
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  // Booking CRUD
  Future<int> insertBooking(UserRequest booking, {String? role}) async {
    final normalizedRole = normalizeRole(role ?? booking.service);
    Database db = await getDatabase(normalizedRole);

    // Normalize worker name for consistency if it's set
    final processedBooking = UserRequest(
      id: booking.id,
      service: booking.service,
      workerName: booking.workerName.trim().toLowerCase(),
      customerName: booking.customerName,
      requestDate: booking.requestDate,
      status: booking.status,
      price: booking.price,
      description: booking.description,
      paymentStatus: booking.paymentStatus,
      transactionId: booking.transactionId,
    );

    int result = await db.insert('bookings', processedBooking.toMap());

    // Create notification for the worker if assigned
    if (processedBooking.workerName != 'pending assignment') {
      await insertNotification(
        NotificationModel(
          title: "New Booking!",
          message:
              "You have a new booking request for ${processedBooking.service} from ${processedBooking.customerName}.",
          date: DateTime.now().toString(),
          type: 'booking',
          recipientName: processedBooking.workerName,
        ),
      );
    }

    return result;
  }

  Future<List<UserRequest>> getBookings({String? role}) async {
    if (role == null) {
      List<UserRequest> allBookings = [];
      for (String r in workerRoles) {
        try {
          Database db = await getDatabase(r);
          List<Map<String, dynamic>> maps = await db.query('bookings');
          allBookings.addAll(
            List.generate(maps.length, (i) {
              return UserRequest.fromMap(maps[i]);
            }),
          );
        } catch (e) {
          // Skip if database/table doesn't exist yet
          continue;
        }
      }
      return allBookings;
    }

    Database db = await getDatabase(role);
    List<Map<String, dynamic>> maps = await db.query('bookings');
    return List.generate(maps.length, (i) {
      return UserRequest.fromMap(maps[i]);
    });
  }

  Future<int> updateBooking(UserRequest booking, {String? role}) async {
    Database db = await getDatabase(role ?? booking.service);
    return await db.update(
      'bookings',
      booking.toMap(),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  Future<int> deleteBooking(int id, {String? role}) async {
    Database db = await getDatabase(role);
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateBookingStatus(
    int id,
    String status, {
    String? role,
    String? workerName,
  }) async {
    Database db = await getDatabase(role);
    Map<String, dynamic> values = {'status': status.toLowerCase()};
    if (workerName != null) {
      values['workerName'] = workerName;
    }
    return await db.update(
      'bookings',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updatePaymentStatus(
    int id,
    String paymentStatus, {
    String? transactionId,
    String? role,
  }) async {
    Database db = await getDatabase(role);
    Map<String, dynamic> values = {'paymentStatus': paymentStatus};
    if (transactionId != null) {
      values['transactionId'] = transactionId;
    }
    return await db.update(
      'bookings',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Job CRUD
  Future<int> insertJob(Job job, {String? role}) async {
    Database db = await getDatabase(role ?? job.category);
    return await db.insert('jobs', job.toMap());
  }

  Future<List<Job>> getJobs({String? role}) async {
    Database db = await getDatabase(role);
    List<Map<String, dynamic>> maps = await db.query('jobs');
    return List.generate(maps.length, (i) {
      return Job.fromMap(maps[i]);
    });
  }

  Future<int> updateJob(Job job, {String? role}) async {
    Database db = await getDatabase(role ?? job.category);
    return await db.update(
      'jobs',
      job.toMap(),
      where: 'id = ?',
      whereArgs: [job.id],
    );
  }

  Future<int> deleteJob(int id, {String? role}) async {
    Database db = await getDatabase(role);
    return await db.delete('jobs', where: 'id = ?', whereArgs: [id]);
  }

  // Review CRUD
  // Review CRUD
  Future<int> insertReview(ReviewModel review, {required String role}) async {
    final normalizedRole = normalizeRole(role.trim());

    debugPrint("💾 insertReview → Role DB ($normalizedRole)");

    // Use role-specific database
    Database db = await getDatabase(normalizedRole);

    try {
      final reviewData = review.toMap();
      // Role is implicit in the database, so we don't strictly need to store it,
      // but if the model has it, we can keep it or remove it from the map if the table doesn't have it.
      // Based on my table creation above, I did NOT include 'role' column in the role-specific table.
      // So I should ensure the map doesn't contain 'role' if the table doesn't support it,
      // OR I should add 'role' to the table definition.
      // The ReviewModel toMap() doesn't include 'role' by default based on previous view.
      // Let's check ReviewModel again. It does NOT have 'role' field.
      // So review.toMap() is safe.

      int result = await db.insert('reviews', reviewData);
      debugPrint("✅ Review inserted! Row ID: $result");

      // Create a notification for the worker
      await insertNotification(
        NotificationModel(
          title: "New Review!",
          message:
              "You received a ${review.rating} star review from ${review.customerName}.",
          date: DateTime.now().toString(),
          type: 'review',
          recipientName: review.workerName,
        ),
      );

      return result;
    } catch (e) {
      debugPrint("❌ Error inserting review: $e");
      rethrow;
    }
  }

  Future<List<ReviewModel>> getReviews({
    required String workerName,
    required String role,
  }) async {
    final normalizedRole = normalizeRole(role.trim());
    final normalizedWorker = workerName.trim().toLowerCase();

    debugPrint("🔍 getReviews → Role DB ($normalizedRole)");
    debugPrint("   Worker: $normalizedWorker");

    // Use role-specific database
    Database db = await getDatabase(normalizedRole);

    List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'LOWER(workerName) = ?',
      whereArgs: [normalizedWorker],
    );

    debugPrint("✅ Found ${maps.length} reviews");

    return maps.map((e) => ReviewModel.fromMap(e)).toList();
  }

  Future<int> deleteReview(int id, {required String role}) async {
    Database db = await getDatabase(role);
    return await db.delete('reviews', where: 'id = ?', whereArgs: [id]);
  }

  Future<double?> getWorkerAverageRating({
    required String workerName,
    required String? role,
  }) async {
    if (role == null) return null;
    final normalizedRole = normalizeRole(role.trim());
    final normalizedWorker = workerName.trim().toLowerCase();

    try {
      Database db = await getDatabase(normalizedRole);
      List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT AVG(rating) as average FROM reviews WHERE LOWER(workerName) = ?',
        [normalizedWorker],
      );

      if (result.isNotEmpty && result.first['average'] != null) {
        return (result.first['average'] as num).toDouble();
      }
    } catch (e) {
      debugPrint("❌ Error calculating average rating: $e");
    }
    return null;
  }

  Future<int> deleteAllReviews({required String role}) async {
    final normalizedRole = normalizeRole(role.trim());
    debugPrint("🗑️ Deleting ALL reviews from $normalizedRole DB");
    Database db = await getDatabase(normalizedRole);
    return await db.delete('reviews');
  }

  // Notification CRUD (Always Main)
  Future<int> insertNotification(NotificationModel notification) async {
    Database db = await getDatabase('main');
    try {
      int result = await db.insert('notifications', notification.toMap());
      debugPrint("🔔 Notification created for ${notification.recipientName}");
      return result;
    } catch (e) {
      debugPrint("❌ Error inserting notification: $e");
      return -1;
    }
  }

  Future<List<NotificationModel>> getNotifications(String recipientName) async {
    Database db = await getDatabase('main');
    final normalizedName = recipientName.trim().toLowerCase();

    List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'LOWER(recipientName) = ?',
      whereArgs: [normalizedName],
      orderBy: 'date DESC',
    );

    return maps.map((e) => NotificationModel.fromMap(e)).toList();
  }

  Future<int> markNotificationAsRead(int id) async {
    Database db = await getDatabase('main');
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNotification(int id) async {
    Database db = await getDatabase('main');
    return await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  // Get Workers by Role
  Future<List<UserModel>> getWorkersByRole(
    String role, {
    bool onlyApproved = true,
  }) async {
    Database db = await getDatabase('main');
    String normalizedRole = role.trim().toLowerCase();

    debugPrint("🔍 getWorkersByRole: Input role=$role");

    String whereClause;
    List<dynamic> whereArgs;

    if (normalizedRole == 'worker') {
      // Admin Panel: Fetch all service providers regardless of specific workType
      whereClause = '(role = ? OR role = ?)';
      whereArgs = ['Worker', 'Goods Taxi'];
    } else if (normalizedRole == 'goods taxi') {
      // User Category or Admin: Fetch all Goods Taxi providers
      whereClause = 'role = ?';
      whereArgs = ['Goods Taxi'];
    } else {
      // User Specific Category: Match the workType exactly (case-insensitive)
      String workTypeToQuery = normalizedRole;

      // Handle common variations in category names vs stored workType
      if (normalizedRole == 'carpentry') workTypeToQuery = 'carpenter';
      if (normalizedRole == 'plumbing') workTypeToQuery = 'plumber';
      if (normalizedRole == 'electricals') workTypeToQuery = 'electrician';
      if (normalizedRole == 'painting') workTypeToQuery = 'painter';
      if (normalizedRole == 'cleaning') workTypeToQuery = 'cleaner';
      if (normalizedRole == 'welding') workTypeToQuery = 'welder';
      if (normalizedRole == 'pest_care' || normalizedRole == 'pest care') {
        workTypeToQuery = 'pest care';
      }

      whereClause = 'LOWER(workType) = ?';
      whereArgs = [workTypeToQuery];
    }

    if (onlyApproved) {
      whereClause += ' AND isApproved = 1';
    }

    debugPrint(
      "🔍 Query: SELECT * FROM users WHERE $whereClause with args=$whereArgs",
    );

    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: whereClause,
      whereArgs: whereArgs,
    );

    debugPrint("✅ getWorkersByRole: Found ${maps.length} results");
    return maps.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<Map<String, int>> getAdminStats() async {
    Database db = await getDatabase('main');
    Map<String, int> stats = {};

    try {
      // Total Users
      List<Map<String, dynamic>> userCount = await db.rawQuery(
        "SELECT COUNT(*) as count FROM users WHERE role = 'User'",
      );
      stats['Users'] = Sqflite.firstIntValue(userCount) ?? 0;

      // Total Workers (All types)
      List<Map<String, dynamic>> workerCount = await db.rawQuery(
        "SELECT COUNT(*) as count FROM users WHERE role = 'Worker' OR role = 'Goods Taxi'",
      );
      stats['Total Workers'] = Sqflite.firstIntValue(workerCount) ?? 0;

      // Approved Workers
      List<Map<String, dynamic>> approvedCount = await db.rawQuery(
        "SELECT COUNT(*) as count FROM users WHERE (role = 'Worker' OR role = 'Goods Taxi') AND isApproved = 1",
      );
      stats['Approved'] = Sqflite.firstIntValue(approvedCount) ?? 0;

      // Pending Workers
      List<Map<String, dynamic>> pendingCount = await db.rawQuery(
        "SELECT COUNT(*) as count FROM users WHERE (role = 'Worker' OR role = 'Goods Taxi') AND isApproved = 0",
      );
      stats['Pending'] = Sqflite.firstIntValue(pendingCount) ?? 0;

      // Workers by category (workType)
      for (String role in workerRoles) {
        String workTypeToQuery = role;
        // Normalize for display and count
        if (role == 'taxi') workTypeToQuery = 'Goods Taxi';

        List<Map<String, dynamic>> categoryCount;
        if (role == 'taxi') {
          categoryCount = await db.rawQuery(
            "SELECT COUNT(*) as count FROM users WHERE role = 'Goods Taxi'",
          );
        } else {
          categoryCount = await db.rawQuery(
            "SELECT COUNT(*) as count FROM users WHERE LOWER(workType) = ?",
            [workTypeToQuery.toLowerCase()],
          );
        }

        int count = Sqflite.firstIntValue(categoryCount) ?? 0;
        if (count > 0) {
          // Capitalize for display
          String label =
              role[0].toUpperCase() + role.substring(1).replaceAll('_', ' ');
          stats[label] = count;
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching admin stats: $e");
    }

    return stats;
  }
}
