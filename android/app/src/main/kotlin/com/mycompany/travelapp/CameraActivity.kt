package com.mycompany.travelapp

import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.widget.Toolbar
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.CameraSelector
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import com.mycompany.travelapp.databinding.ActivityCameraBinding
import com.mycompany.travelapp.databinding.FragmentCameraBinding
import com.mycompany.travelapp.mediapipe.CameraFragment

class CameraActivity : AppCompatActivity() {
    private var _activityCameraBinding: ActivityCameraBinding? = null
    private var cameraFacing = CameraSelector.LENS_FACING_FRONT
    private val activityCameraBinding
        get() = _activityCameraBinding!!

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_camera)

        _activityCameraBinding = ActivityCameraBinding.inflate(layoutInflater)

        supportActionBar?.setDisplayHomeAsUpEnabled(true) // Enable back button
        supportActionBar?.title = "Translation"
        supportActionBar?.setBackgroundDrawable(
            ColorDrawable(
                ContextCompat.getColor(
                    this,
                    R.color.mp_color_primary
                )
            )
        )

        if (savedInstanceState == null) {
            loadCameraFragment()
        }
    }

    // Inflate the menu
    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.camera_menu, menu)
        return true
    }

    // Handle toggle button click
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_toggle_camera -> {
                toggleCameraFacing()
                true
            }

            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun toggleCameraFacing() {
        cameraFacing = if (cameraFacing == CameraSelector.LENS_FACING_FRONT) {
            CameraSelector.LENS_FACING_BACK
        } else {
            CameraSelector.LENS_FACING_FRONT
        }

        loadCameraFragment()
    }

    private fun loadCameraFragment() {
        supportFragmentManager.beginTransaction()
            .replace(R.id.camera_layout, CameraFragment(cameraFacing))
            .commit()
    }
}