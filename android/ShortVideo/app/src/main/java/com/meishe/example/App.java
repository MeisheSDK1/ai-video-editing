package com.meishe.example;

import android.app.Application;
import android.content.Context;

import androidx.multidex.MultiDex;

import com.blankj.utilcode.util.LogUtils;
import com.meishe.module.NvModuleManager;


/**
 * @author zcy
 * @Destription:
 * @Emial:
 * @CreateDate: 2022/1/17.
 */
public class App extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        NvModuleManager.get().init(this);
        LogUtils.getConfig().setLogSwitch(true);
        String mLicPath = "assets:/meishesdk.lic";
        NvModuleManager.get().initSdk(mLicPath);
        NvModuleManager.get().initModel();
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(base);
    }
}
