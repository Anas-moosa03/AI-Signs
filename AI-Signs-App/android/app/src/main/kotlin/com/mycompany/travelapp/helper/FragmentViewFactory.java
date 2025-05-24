package com.mycompany.travelapp.helper;

import android.content.Context;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import java.util.Map;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class FragmentViewFactory extends PlatformViewFactory {
    private final FragmentManager fragmentManager;

    public FragmentViewFactory(FragmentManager fragmentManager) {
        super(StandardMessageCodec.INSTANCE);
        this.fragmentManager = fragmentManager;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Map<String, Object> creationParams = (Map<String, Object>) args;
        return new FragmentPlatformView(context, fragmentManager, viewId, creationParams);
    }
}