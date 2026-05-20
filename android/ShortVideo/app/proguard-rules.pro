# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

#指定压缩级别
-optimizationpasses 5

#不跳过非公共的库的类成员
-dontskipnonpubliclibraryclassmembers

#混淆时采用的算法
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

#把混淆类中的方法名也混淆了
-useuniqueclassmembernames

#优化时允许访问并修改有修饰符的类和类的成员
-allowaccessmodification

#将文件来源重命名为“SourceFile”字符串
-renamesourcefileattribute SourceFile
#保留行号
-keepattributes SourceFile,LineNumberTable
#保持泛型
-keepattributes Signature

# 保留Annotation不混淆
-keepattributes *Annotation*,InnerClasses
#google推荐算法
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
# 避免混淆Annotation、内部类、泛型、匿名类
-keepattributes *Annotation*,InnerClasses,Signature,EnclosingMethod
# 重命名抛出异常时的文件名称
-renamesourcefileattribute SourceFile
# 抛出异常时保留代码行号
-keepattributes SourceFile,LineNumberTable
# 处理support包
-dontnote android.support.**
-dontwarn android.support.**

# 保留R下面的资源
-keep class **.R$* {*;}

-keep class com.umeng.** {*;}

-keep class com.uc.** {*;}

-keep class com.zui.** {*;}
-keep class com.miui.** {*;}
-keep class com.heytap.** {*;}
-keep class a.** {*;}
-keep class com.vivo.** {*;}
-keep public class com.meishe.myvideoapp.R$*{
    public static final int *;
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

#保持所有实现 Serializable 接口的类成员
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

-keep public class * implements java.io.Serializable {*;}

 # 保持Parcelable不被混淆
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# 对于带有回调函数的onXXEvent、**On*Listener的，不能被混淆
-keepclassmembers class * {
    void *(**On*Event);
    void *(**On*Listener);
}

# 保留本地native方法不被混淆
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保持测试相关的代码 start
-dontnote junit.framework.**
-dontnote junit.runner.**
-dontwarn android.test.**
-dontwarn android.support.test.**
-dontwarn org.junit.**
# 保持测试相关的代码 end

#阿里云 start
-keep class com.alibaba.sdk.android.oss.** { *; }
-dontwarn okio.**
-dontwarn org.apache.commons.codec.binary.**
#阿里云 end

#EventBus start
-keepattributes *Annotation*
-keepclassmembers class * {
    @org.greenrobot.eventbus.Subscribe <methods>;
}
-keep enum org.greenrobot.eventbus.ThreadMode { *; }

# And if you use AsyncExecutor:
-keepclassmembers class * extends org.greenrobot.eventbus.util.ThrowableFailureEvent {
    <init>(java.lang.Throwable);
}
#EventBus end

#Glide start
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep public enum com.bumptech.glide.load.resource.bitmap.ImageHeaderParser$** {
  **[] $VALUES;
  public *;
}
#Glide end

#fresco start
-keep class com.facebook.fresco.** { *; }
-keep,allowobfuscation @interface com.facebook.common.internal.DoNotStrip
-keep @com.facebook.common.internal.DoNotStrip class *
-keepclassmembers class * {
     @com.facebook.common.internal.DoNotStrip *;
}
-keep class com.facebook.imagepipeline.gif.** { *; }
-keep class com.facebook.imagepipeline.webp.* { *; }
-keepclassmembers class * {
    native <methods>;
}
-keep class com.facebook.imagepipeline.animated.factory.AnimatedFactoryImpl {
    public AnimatedFactoryImpl(com.facebook.imagepipeline.bitmaps.PlatformBitmapFactory,com.facebook.imagepipeline.core.ExecutorSupplier);
}
#fresco end

#webView start
-keepclassmembers class fqcn.of.javascript.interface.for.Webview {
   public *;
}
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, jav.lang.String);
}
#在app中与HTML5的JavaScript的交互进行特殊处理
#我们需要确保这些js要调用的原生方法不能够被混淆，于是我们需要做如下处理：
-keepclassmembers class com.ljd.example.JSInterface {
    <methods>;
}
#webView end

##---------------Gson start  ----------
# Gson uses generic type information stored in a class file when working with fields. Proguard
# removes such information by default, so configure it to keep all of it.

# For using GSON @Expose annotation
# Gson specific classes
-keep class sun.misc.Unsafe { *; }
#-keep class com.google.gson.stream.** { *; }

-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type
##---------------Gson end  ----------

-keep class com.meishe.base.model.** { *; }

#-keep public class * extends com.meishe.base.model.IBaseVie
#（可选）避免Log打印输出
-assumenosideeffects class android.util.Log {
   public static *** v(...);
   public static *** d(...);
   public static *** i(...);
   public static *** w(...);
 }

 #greendao start
 -keepclassmembers class * extends org.greenrobot.greendao.AbstractDao {
     public static void dropTable(org.greenrobot.greendao.database.Database, boolean);
     public static void createTable(org.greenrobot.greendao.database.Database, boolean);
 }


 -keepclassmembers class * extends org.greenrobot.greendao.AbstractDao {
 public static java.lang.String TABLENAME;
 }
 -keep class **$Properties { *; }

 # If you DO use SQLCipher:
 -keep class org.greenrobot.greendao.database.SqlCipherEncryptedHelper { *; }

 # If you do NOT use SQLCipher:
 -dontwarn net.sqlcipher.database.**
 # If you do NOT use RxJava:
 -dontwarn rx.**
 #greendao end


#okhttp3 start
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
#okhttp3 end

# Okio start
-dontwarn com.squareup.**
-dontwarn okio.**
-keep public class org.codehaus.* { *; }
-keep public class java.nio.* { *; }
#Okio end

-dontwarn javax.annotation.**

-keep class * extends com.meishe.libbase.base.Presenter
-keep class * extends com.meishe.libbase.base.IBaseView
-keepclasseswithmembers class * extends android.view.View {
    public <init>(android.content.Context);
}
-keepclasseswithmembers class * extends android.view.View {
    public <init>(android.content.Context, android.util.AttributeSet);
}
-keepclasseswithmembers class * extends android.view.View {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}
-keep class com.cdv.**  {*;}
-keep class com.meicam.** {*;}
-keep class com.cdv.effect.** {*;}
-keep class com.meicam.effect.** {*;}
-keep class com.meishe.photo.** {*;}
-keep class com.meishe.libbase.** {*;}
-keep class com.meishe.modulearscene.** {*;}
-keep class com.meishe.autocaption.** {*;}
-keep class com.meishe.** {*;}
-keep class com.example.libasset.** {*;}

