# Razorpay rules
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keep class * extends java.util.ListResourceBundle { protected Object[][] getContents(); }
-keepattributes *Annotation*
-keepclasseswithmembers class * { public <init>(android.content.Context, android.util.AttributeSet); }
-keepclasseswithmembers class * { public <init>(android.content.Context, android.util.AttributeSet, int); }
-keepclassmembers class * implements android.os.Parcelable { static ** CREATOR; }

# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }