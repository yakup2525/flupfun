# Room creates generated database implementations by reflection.
# Preserve their no-argument constructor when R8 full mode shrinks release builds.
# WorkManager initializes its database before Flutter starts.
# Upstream fix: https://android.googlesource.com/platform/frameworks/support/+/e4765e38e27a3f4d86188b996df97a52403dff46
-keep class * extends androidx.room.RoomDatabase { void <init>(); }
