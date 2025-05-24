package com.mycompany.travelapp.view

import android.content.Context
import android.view.SurfaceView
import androidx.camera.core.*
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.lifecycle.LifecycleOwner
import com.google.common.util.concurrent.ListenableFuture
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.mycompany.travelapp.mediapipe.SignLandmarkerHelper
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class CameraXView(context: Context) : SurfaceView(context),
    SignLandmarkerHelper.HandLandmarkerListener, SignLandmarkerHelper.PoseLandmarkerListener {
    private val cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private var handLandmarkerHelper: SignLandmarkerHelper? = null
    private var cameraFacing = CameraSelector.LENS_FACING_FRONT

    init {
        setup()
        startCamera()
    }

    private fun setup() {
        handLandmarkerHelper = SignLandmarkerHelper(
            context = context,
            runningMode = RunningMode.LIVE_STREAM,
            minHandDetectionConfidence = 0.5f,
            minHandTrackingConfidence = 0.5f,
            minHandPresenceConfidence = 0.5f,
            maxNumHands = 2,
            currentDelegate = 0,
            handLandmarkerHelperListener = this
        )
    }

    private fun startCamera() {
        val cameraProviderFuture: ListenableFuture<ProcessCameraProvider> =
            ProcessCameraProvider.getInstance(context)

        cameraProviderFuture.addListener({
            val cameraProvider: ProcessCameraProvider = cameraProviderFuture.get()

            val preview = Preview.Builder().build().also {
                it.surfaceProvider = Preview.SurfaceProvider { request ->
                    val surface = holder.surface
                    request.provideSurface(surface, cameraExecutor) { result ->
                        // Handle the result if needed
                    }
                }
            }

            val imageAnalyzer =
                ImageAnalysis.Builder().setTargetAspectRatio(AspectRatio.RATIO_4_3)
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                    .build()
                    // The analyzer can then be assigned to the instance
                    .also {
                        it.setAnalyzer(cameraExecutor) { image ->
                            handLandmarkerHelper?.detectLiveStream(
                                imageProxy = image,
                                isFrontCamera = cameraFacing == CameraSelector.LENS_FACING_FRONT
                            )
                        }
                    }

            imageAnalyzer.setAnalyzer(cameraExecutor) { image ->
                val buffer = image.planes[0].buffer
                val data = ByteArray(buffer.remaining())
                buffer.get(data)
                image.close()
            }

            val cameraSelector =
                CameraSelector.Builder().requireLensFacing(cameraFacing).build()

            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    context as LifecycleOwner,
                    cameraSelector,
                    preview,
                    imageAnalyzer
                )
            } catch (exc: Exception) {
                exc.printStackTrace()
            }
        }, cameraExecutor)
    }



    override fun onHandError(error: String, errorCode: Int) {
        TODO("Not yet implemented")
    }

    override fun onHandResults(handResultBundle: SignLandmarkerHelper.HandResultBundle) {
        TODO("Not yet implemented")
    }

    override fun onPoseError(error: String, errorCode: Int) {
        TODO("Not yet implemented")
    }

    override fun onPoseResults(handResultBundle: SignLandmarkerHelper.PoseResultBundle) {
        TODO("Not yet implemented")
    }
}
