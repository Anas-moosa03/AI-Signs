package com.mycompany.travelapp.helper;

import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.widget.FrameLayout;

import androidx.camera.core.CameraSelector;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.mycompany.travelapp.mediapipe.CameraFragment;

import java.util.Map;

import io.flutter.plugin.platform.PlatformView;

public class FragmentPlatformView implements PlatformView {
    private final View fragmentView;
    private CameraFragment cameraFragment;

    public FragmentPlatformView(Context context, FragmentManager fragmentManager, int containerId, Map<String, Object> creationParams) {
//        this.fragment = fragment;

        cameraFragment = new CameraFragment(CameraSelector.LENS_FACING_FRONT);
        // Get the width and height from creationParams
        int width = (int) creationParams.get("width");
        int height = (int) creationParams.get("height");
        int paddingLeft = (int) creationParams.get("paddingLeft");
        int paddingTop = (int) creationParams.get("paddingTop");
        int paddingRight = (int) creationParams.get("paddingRight");
        int paddingBottom = (int) creationParams.get("paddingBottom");

        // Create a container view for the fragment
        fragmentView = new FrameLayout(context);
        fragmentView.setLayoutParams(new FrameLayout.LayoutParams(
                width,  // Set width from Flutter
                height  // Set height from Flutter
        ));
        fragmentView.setId(containerId);

        // Pass the size as arguments
        Bundle args = new Bundle();
        args.putInt("width", width);
        args.putInt("height", height);
        args.putInt("paddingLeft", paddingLeft);
        args.putInt("paddingTop", paddingTop);
        args.putInt("paddingRight", paddingRight);
        args.putInt("paddingBottom", paddingBottom);
        cameraFragment.setArguments(args);

        // Add the fragment to the container
        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.add(containerId, cameraFragment);
        transaction.commit();
    }

    @Override
    public View getView() {
        return fragmentView;
    }

    @Override
    public void dispose() {
        if (cameraFragment != null) {
            FragmentTransaction transaction = cameraFragment.getParentFragmentManager().beginTransaction();
//            transaction.remove(cameraFragment);
            transaction.remove(cameraFragment);
            transaction.commitNow();
            cameraFragment = null;
        }
    }
}