package com.meishe.example;

import static com.meishe.common.UIConfig.sNeedFlash;
import static com.meishe.common.views.PermissionsActivity.PERMISSIONS_NO_PROMPT;
import static com.meishe.engine.util.PathUtils.APP_TAG;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.blankj.utilcode.util.BarUtils;
import com.blankj.utilcode.util.LogUtils;
import com.meishe.common.Constants;
import com.meishe.common.UIConfig;
import com.meishe.config.NvEditConfig;
import com.meishe.config.NvShadowOffsetConfig;
import com.meishe.config.NvVideoConfig;
import com.meishe.engine.util.PathUtils;
import com.meishe.libbase.manager.AppManager;
import com.meishe.libbase.utils.AndroidVersionUtils;
import com.meishe.libbase.utils.ToastUtil;
import com.meishe.libbase.utils.Utils;
import com.meishe.module.ModuleConstants;
import com.meishe.module.NvModuleManager;
import com.meishe.module.interfaces.ModuleManager;
import com.meishe.module.interfaces.NvModuleManagerCallback;
import com.meishe.photo.utils.RoomUtil;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {
    private boolean isAssetConfig = false;

    private FrameLayout mFlSplashContainer;
    private RelativeLayout mRlFunctionContainer;
    private TextView mTvFlashText;

    private NvVideoConfig mVideoConfig;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        BarUtils.transparentStatusBar(this);
        setContentView(R.layout.activity_main);
        initView();
        initData();
        NvModuleManager.get().downloadPrefabricatedMaterial(MainActivity.this, mAssetsRequestListener);
    }

    private ModuleManager.OnAssetsRequestListener mAssetsRequestListener = isSuccess -> LogUtils.i("downloadPrefabricatedMaterial result is " + isSuccess);

    protected void initData() {
        if (sNeedFlash) {
            startAnimation();
        } else {
            doAfterSplash();
        }
        String configPath = "assets:/config/config_example.json";
        if (!isAssetConfig) {
            String rootPath = AndroidVersionUtils.isAboveAndroid_Q() ? "" : APP_TAG + File.separator;
            String rootFilePath = PathUtils.getFolderDirPath(rootPath) + File.separator + "Config";
            File rootFile = new File(rootFilePath);
            if (!rootFile.exists()) {
                rootFile.mkdirs();
            }
            configPath = rootFilePath + File.separator + "config_example.json";
        }
        NvModuleManager.get().initConfig(configPath);
        //测试阴影层配置 test shadow layer config
//        testShadowLayer();
//        testMenuNextAndSave();
    }

    private void testMenuNextAndSave() {
        mVideoConfig = NvModuleManager.get().getConfig();
        if (null == mVideoConfig) {
            mVideoConfig = new NvVideoConfig();
        }
        NvEditConfig editConfig = mVideoConfig.getEditConfig();
        if (null == editConfig) {
            editConfig = new NvEditConfig();
        }
        List<NvEditConfig.NvEditMenuItem> editMenuItems = editConfig.getEditMenuItems();
        if (null == editMenuItems) {
            editMenuItems = new ArrayList<>();
        }
        editMenuItems.add(NvEditConfig.NvEditMenuItem.release);
        editMenuItems.add(NvEditConfig.NvEditMenuItem.download);
        editMenuItems.add(NvEditConfig.NvEditMenuItem.edit);
        editMenuItems.add(NvEditConfig.NvEditMenuItem.text);
        editMenuItems.add(NvEditConfig.NvEditMenuItem.sticker);
        editMenuItems.add(NvEditConfig.NvEditMenuItem.effect);
        editMenuItems.add(NvEditConfig.NvEditMenuItem.filter);
        editMenuItems.add(NvEditConfig.NvEditMenuItem.caption);
        editMenuItems.add(NvEditConfig.NvEditMenuItem.audio);
        editMenuItems.add(NvEditConfig.NvEditMenuItem.record);
        editConfig.setEditMenuItems(editMenuItems);

//        Map<String, Object> customTheme = new HashMap<>();
//        NvButtonTheme releaseButton = new NvButtonTheme();
//        releaseButton.setImageName("ic_pop_cancel");
//        customTheme.put(NvKey.NvEditLeftMenuReleaseBtKey, releaseButton);
//        editConfig.setCustomTheme(customTheme);
        mVideoConfig.setEditConfig(editConfig);
    }

    private void testShadowLayer() {
        mVideoConfig = NvModuleManager.get().getConfig();
        if (null == mVideoConfig) {
            mVideoConfig = new NvVideoConfig();
        }
        mVideoConfig.setShadowColor("#FC3E5A");
        NvShadowOffsetConfig nvShadowOffsetConfig = new NvShadowOffsetConfig(0, 1);
        mVideoConfig.setShadowOffset(nvShadowOffsetConfig);
    }

    private void startAnimation() {
        mTvFlashText.setVisibility(View.VISIBLE);
        ObjectAnimator alpha = ObjectAnimator.ofFloat(mTvFlashText, "alpha", 1f, 1f);
        ObjectAnimator scaleX = ObjectAnimator.ofFloat(mTvFlashText, "scaleX", 1f, 1f);
        ObjectAnimator scaleY = ObjectAnimator.ofFloat(mTvFlashText, "scaleY", 1f, 1f);
        AnimatorSet animatorSet = new AnimatorSet();
        animatorSet.setDuration(1500);
        animatorSet.playTogether(alpha, scaleX, scaleY);
        animatorSet.start();
        animatorSet.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationStart(Animator animation, boolean isReverse) {
                super.onAnimationStart(animation, isReverse);
            }

            @Override
            public void onAnimationEnd(Animator animation, boolean isReverse) {
                super.onAnimationEnd(animation, isReverse);
                doAfterSplash();
            }
        });
    }

    private void doAfterSplash() {
        mFlSplashContainer.setVisibility(View.GONE);
        mRlFunctionContainer.setVisibility(View.VISIBLE);
    }

    protected void initView() {
        mFlSplashContainer = findViewById(R.id.fl_splash_container);
        mRlFunctionContainer = findViewById(R.id.rl_main_container);
        mTvFlashText = findViewById(R.id.tv_flash_text);
        ImageView mPicture = findViewById(R.id.iv_picture);
        mPicture.setImageResource(Utils.isZh() ? R.mipmap.home_picture : R.mipmap.home_picture_en);
        TextView tvVersion = findViewById(R.id.ms_version);
        String version = getString(R.string.app_name) + " " + RoomUtil.getVersion(getApplicationContext());
        tvVersion.setText(version);
        /*findViewById(R.id.iv_setting).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Utils.isFastClick()) {
                    return;
                }
                AppManager.getInstance().jumpActivity(MainActivity.this, SettingActivity.class);
            }
        });*/
        View captureBtn = findViewById(R.id.capture);
        captureBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (Utils.isFastClick()) {
                    return;
                }
                NvModuleManager.get().openCapture(MainActivity.this, mVideoConfig, null, mAssetsRequestListener);
            }
        });

        View editBtn = findViewById(R.id.edit);
        editBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Utils.isFastClick()) {
                    return;
                }
                NvModuleManager.get().openEdit(MainActivity.this, mVideoConfig, mAssetsRequestListener);
            }
        });
        View dualBtn = findViewById(R.id.dual_capture);
        dualBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (Utils.isFastClick()) {
                    return;
                }
                NvModuleManager.get().startDualCapture(MainActivity.this, mVideoConfig, mAssetsRequestListener);
            }
        });
        findViewById(R.id.dual_draft).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Utils.isFastClick()) {
                    return;
                }
                NvModuleManager.get().openDraftActivity(MainActivity.this, mVideoConfig, UIConfig.get().getDraftActivity());
            }
        });
        NvModuleManager.get().setModuleManagerCallback(new NvModuleManagerCallback() {
            @Override
            public void publishWithInfo(Activity activity, boolean needSaveDraft, boolean needSaveCover, boolean needSaveVideo, String videoPath) {
                try {
                    Bundle bundle = new Bundle();
                    bundle.putBoolean("intent_key_can_save_draft", needSaveDraft);
                    bundle.putBoolean("intent_key_can_save_cover", needSaveCover);
                    bundle.putBoolean("intent_key_can_save_video", needSaveVideo);
                    bundle.putString("intent_key_video_path", videoPath);
                    Class<?> aClass = Class.forName(ModuleConstants.PUBLISH_ACTIVITY);
                    AppManager.getInstance().jumpActivity(activity,
                            (Class<? extends Activity>) aClass, bundle);
                } catch (ClassNotFoundException e) {
                    throw new RuntimeException(e);
                }
            }

        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == Constants.REQUEST_CHECK_PERMISSION_CODE && resultCode == PERMISSIONS_NO_PROMPT) {
            ToastUtil.showToast(this, R.string.no_permission);
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        NvModuleManager.get().destroy();
    }
}
