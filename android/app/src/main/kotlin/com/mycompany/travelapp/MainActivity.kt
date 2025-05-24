package com.mycompany.travelapp

import android.content.Intent
import androidx.fragment.app.FragmentManager
import com.mycompany.travelapp.helper.FragmentViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

//class MainActivity : FlutterFragmentActivity() {
class MainActivity : FlutterActivity() {
    companion object {
        lateinit var methodChannel: MethodChannel
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.mycompany.travelapp/hand_tracking"
        )

//        val fragmentManager: FragmentManager = supportFragmentManager
//        val registry = flutterEngine.platformViewsController.registry
//        registry.registerViewFactory("camerax-fragment-view", FragmentViewFactory(fragmentManager))

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.mycompany.travelapp/hand_tracking").setMethodCallHandler { call, result ->
            if (call.method == "openCameraActivity") {
                val intent = Intent(this, CameraActivity::class.java)
                startActivity(intent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

    }
}