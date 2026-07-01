# ProGuard Rules untuk Flutter
-keep class io.flutter.** { *; }
-keep class com.google.** { *; }
-keepattributes *Annotation*
-dontwarn com.google.**

# Retain Kotlin metadata
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Don't obfuscate annotations
-keepattributes *Annotation*
