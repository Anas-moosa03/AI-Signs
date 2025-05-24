/*
 * Copyright 2022 The TensorFlow Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.mycompany.travelapp.mediapipe

import TFLiteModelHelper
import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Configuration
import android.hardware.camera2.CaptureRequest
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.text.method.ScrollingMovementMethod
import android.util.DisplayMetrics
import android.util.Log
import android.util.Range
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.widget.FrameLayout
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.camera2.interop.Camera2Interop
import androidx.camera.core.AspectRatio
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import com.mycompany.travelapp.MainActivity
import com.mycompany.travelapp.R
import com.mycompany.travelapp.databinding.FragmentCameraBinding
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import kotlin.math.pow
import kotlin.math.sqrt


class CameraFragment(val cameraFacingParam: Int) : Fragment(),
    SignLandmarkerHelper.HandLandmarkerListener,
    SignLandmarkerHelper.PoseLandmarkerListener {

    inner class FrameBuffer(private val maxSize: Int) {
        private val buffer = ArrayDeque<FloatArray>()

        fun addFrame(frame: FloatArray) {
            if (buffer.size >= maxSize) buffer.removeFirst()
            buffer.addLast(frame)
        }

        fun getFrames(): Array<FloatArray> = buffer.toTypedArray()
        fun isFull() = buffer.size == maxSize
    }

    companion object {
        private const val TAG = "Camera Fragment"
        private const val CAPACITY = 45
    }

    private var _fragmentCameraBinding: FragmentCameraBinding? = null
    private var tfLiteModelHelper: TFLiteModelHelper? = null

    private val fragmentCameraBinding
        get() = _fragmentCameraBinding!!

    private lateinit var signLandmarkerHelper: SignLandmarkerHelper
    private val viewModel: MainViewModel by activityViewModels()
    private var preview: Preview? = null
    private var imageAnalyzer: ImageAnalysis? = null
    private var camera: Camera? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var cameraFacing = cameraFacingParam

    private var handLandmarkerResults: HandLandmarkerResult? = null
    private var poseLandmarkerResult: PoseLandmarkerResult? = null
    private var isCameraWorking = false

    /** Blocking ML operations are performed using this executor */
    private lateinit var backgroundExecutor: ExecutorService

    override fun onResume() {
        super.onResume()
        Log.d("CameraFragment", "onResume")
        // Make sure that all permissions are still present, since the
        // user could have removed them while the app was in paused state.
//        if (!PermissionsFragment.hasPermissions(requireContext())) {
//            Navigation.findNavController(
//                requireActivity(), R.id.fragment_container
//            ).navigate(R.id.action_camera_to_permissions)
//        }

        // Start the HandLandmarkerHelper again when users come back
        // to the foreground.
        backgroundExecutor.execute {
            if (signLandmarkerHelper.isClose()) {
                signLandmarkerHelper.setupHandLandmarker()
                signLandmarkerHelper.setupPoseLandmarker()
            }
        }
    }

    override fun onPause() {
        Log.d("CameraFragment", "onPause")
        super.onPause()
        if (this::signLandmarkerHelper.isInitialized) {
            viewModel.setMaxHands(signLandmarkerHelper.maxNumHands)
            viewModel.setMinHandDetectionConfidence(signLandmarkerHelper.minHandDetectionConfidence)
            viewModel.setMinHandTrackingConfidence(signLandmarkerHelper.minHandTrackingConfidence)
            viewModel.setMinHandPresenceConfidence(signLandmarkerHelper.minHandPresenceConfidence)
            viewModel.setDelegate(signLandmarkerHelper.currentDelegate)

            // Close the HandLandmarkerHelper and release resources
            backgroundExecutor.execute { signLandmarkerHelper.clearHandLandmarker(); signLandmarkerHelper.clearHandLandmarker() }
        }
    }

    override fun onDestroyView() {
        Log.d("CameraFragment", "onDestroyView")
        _fragmentCameraBinding = null

        super.onDestroyView()
        tfLiteModelHelper?.clearSentence()
        inferenceScope.cancel()
        tfLiteModelHelper = null
//        _fragmentCameraBinding?.overlay?.clear()
        cameraProvider?.shutdownAsync()
        cameraProvider?.unbindAll()
        backgroundExecutor.execute { signLandmarkerHelper.clearHandLandmarker(); signLandmarkerHelper.clearPoseLandmarker() }
        // Shut down our background executor
        backgroundExecutor.shutdown()
        backgroundExecutor.awaitTermination(
            Long.MAX_VALUE, TimeUnit.NANOSECONDS
        )
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        Log.d("CameraFragment", "onCreateView")
        _fragmentCameraBinding =
            FragmentCameraBinding.inflate(inflater, container, false)

        return fragmentCameraBinding.root
    }

    fun convertDpToPixel(dp: Int, context: Context): Float {
        return dp.toFloat() * (context.resources
            .displayMetrics.densityDpi.toFloat() / DisplayMetrics.DENSITY_DEFAULT.toFloat())
    }

    @SuppressLint("MissingPermission")
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        Log.d("CameraFragment", "OnViewCreated")

//        val toolbar = fragmentCameraBinding.toolbar
//        (requireActivity() as AppCompatActivity).setSupportActionBar(toolbar)
//
//        val actionBar = (requireActivity() as AppCompatActivity).supportActionBar
//        actionBar?.setDisplayHomeAsUpEnabled(true) // Enables default back button
//
//        // Handle back button click
//        toolbar.setNavigationOnClickListener {
//            requireActivity().onBackPressedDispatcher.onBackPressed()
//        }

        // Get the width and height from arguments
//        val width = arguments?.getInt("width")
//        val height = arguments?.getInt("height")
//        val padL = arguments?.getInt("paddingLeft") ?: 0
//        val padT = arguments?.getInt("paddingTop") ?: 0
//        val padR = arguments?.getInt("paddingRight") ?: 0
//        val padB = arguments?.getInt("paddingBottom") ?: 0
//        if (width != null && height != null) {
//            val fp: FrameLayout.LayoutParams =
//                FrameLayout.LayoutParams(
//                    convertDpToPixel(width, requireContext()).toInt(),
//                    convertDpToPixel(height, requireContext()).toInt()
//                )
//            // Adjust the root view's size
//            fp.setMargins(
//                convertDpToPixel(padL, requireContext()).toInt(),
//                convertDpToPixel(padT, requireContext()).toInt(),
//                convertDpToPixel(padR, requireContext()).toInt(),
//                convertDpToPixel(padB, requireContext()).toInt()
//            )
//            _fragmentCameraBinding?.root?.layoutParams = fp
//
//            val preDrawListener = object : ViewTreeObserver.OnPreDrawListener {
//                override fun onPreDraw(): Boolean {
//                    Log.d("CameraFragment", "FrameLayout is about to be drawn!")
//                    _fragmentCameraBinding?.viewFinder?.viewTreeObserver?.removeOnPreDrawListener(
//                        this
//                    ) // Remove listener
//                    return true // Allow drawing to continue
//                }
//            }
//
//            _fragmentCameraBinding?.viewFinder?.viewTreeObserver?.addOnPreDrawListener(
//                preDrawListener
//            )
//            // Set a timeout to check if it's never drawn
//            Handler(Looper.getMainLooper()).postDelayed({
//                if (_fragmentCameraBinding?.viewFinder?.viewTreeObserver?.isAlive == true) {
//                    _fragmentCameraBinding?.viewFinder?.viewTreeObserver?.removeOnPreDrawListener(
//                        preDrawListener
//                    )
//                    Log.e("CameraFragment", "FrameLayout was NOT drawn!")
//                    MainActivity.methodChannel.invokeMethod("cameraStatus", false)
//                }
//            }, 3000) // Timeout after 3 seconds
//
////            _fragmentCameraBinding?.root?.addOnLayoutChangeListener { _, _, _, _, _, _, _, _, _ ->
////                if (frameLayout.width > 0 && frameLayout.height > 0) {
////                    Log.d("CameraFragment", "FrameLayout is now visible!")
////
////                    // Send success message to Flutter
////                    MainActivity.methodChannel.invokeMethod("cameraStatus", true)
////                }
////            }
//
//            // Adjust the camera preview size dynamically
////            _fragmentCameraBinding?.viewFinder?.layoutParams = lp
////            _fragmentCameraBinding?.overlay?.layoutParams = lp
//        }


        // Initialize our background executor
        backgroundExecutor = Executors.newSingleThreadExecutor()

        // Wait for the views to be properly laid out
        fragmentCameraBinding.viewFinder.post {
            // Set up the camera and its use cases
            setUpCamera()
        }

        fragmentCameraBinding.textView.movementMethod = ScrollingMovementMethod()

        // Create the HandLandmarkerHelper that will handle the inference
        backgroundExecutor.execute {
            signLandmarkerHelper = SignLandmarkerHelper(
                context = requireContext(),
                runningMode = RunningMode.LIVE_STREAM,
                minHandDetectionConfidence = viewModel.currentMinHandDetectionConfidence,
                minHandTrackingConfidence = viewModel.currentMinHandTrackingConfidence,
                minHandPresenceConfidence = viewModel.currentMinHandPresenceConfidence,
                maxNumHands = viewModel.currentMaxHands,
                currentDelegate = viewModel.currentDelegate,
                handLandmarkerHelperListener = this,
                poseLandmarkerHelperListener = this
            )
            tfLiteModelHelper = TFLiteModelHelper(requireContext())

        }

        // Attach listeners to UI control widgets
//        initBottomSheetControls()
    }

    // Initialize CameraX, and prepare to bind the camera use cases
    private fun setUpCamera() {
        Log.d(TAG, "SetUp Camera")
        val cameraProviderFuture =
            ProcessCameraProvider.getInstance(requireContext())
        cameraProviderFuture.addListener(
            {
                // CameraProvider
                cameraProvider = cameraProviderFuture.get()

                // Build and bind the camera use cases
                bindCameraUseCases()
            }, ContextCompat.getMainExecutor(requireContext())
        )
    }

    // Declare and bind preview, capture and analysis use cases
    @SuppressLint("UnsafeOptInUsageError")
    private fun bindCameraUseCases() {

        // CameraProvider
        val cameraProvider = cameraProvider
            ?: throw IllegalStateException("Camera initialization failed.")

        val cameraSelector =
            CameraSelector.Builder().requireLensFacing(cameraFacing).build()

        // Preview. Only using the 4:3 ratio because this is the closest to our models
        val previewBuilder = Preview.Builder().setTargetAspectRatio(AspectRatio.RATIO_4_3)
            .setTargetRotation(fragmentCameraBinding.viewFinder.display.rotation)
            .setTargetFrameRate(Range(30, 30))

        val previewExtender = Camera2Interop.Extender(previewBuilder)
        previewExtender.setCaptureRequestOption(
            CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE,
            Range(30, 30)
        )

        preview = previewBuilder.build()

        // ImageAnalysis. Using RGBA 8888 to match how our models work
        val imageAnalyzerBuilder =
            ImageAnalysis.Builder().setTargetAspectRatio(AspectRatio.RATIO_4_3)
                .setTargetRotation(fragmentCameraBinding.viewFinder.display.rotation)
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)

        val analysisExtender = Camera2Interop.Extender(imageAnalyzerBuilder)
        analysisExtender.setCaptureRequestOption(
            CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE,
            Range(15, 30)
        )

        imageAnalyzer = imageAnalyzerBuilder
            .build()
            // The analyzer can then be assigned to the instance
            .also {
                it.setAnalyzer(backgroundExecutor) { image ->
                    detectKeypoints(image)
                }
            }
        // Must unbind the use-cases before rebinding them
        cameraProvider.unbindAll()

        try {
            // A variable number of use-cases can be passed here -
            // camera provides access to CameraControl & CameraInfo

            camera = cameraProvider.bindToLifecycle(
                this, cameraSelector, preview, imageAnalyzer
            )

            // Attach the viewfinder's surface provider to preview use case
            preview?.surfaceProvider = fragmentCameraBinding.viewFinder.surfaceProvider

//            isCameraWorking = true
//            MainActivity.methodChannel.invokeMethod("cameraStatus", true)


        } catch (exc: Exception) {
            Log.e(TAG, "Use case binding failed", exc)
        }
    }

    private fun detectKeypoints(imageProxy: ImageProxy) {
        signLandmarkerHelper.detectLiveStream(
            imageProxy = imageProxy,
            isFrontCamera = cameraFacing == CameraSelector.LENS_FACING_FRONT
        )
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        imageAnalyzer?.targetRotation =
            fragmentCameraBinding.viewFinder.display.rotation
    }


    override fun onHandError(error: String, errorCode: Int) {
        activity?.runOnUiThread {
            Toast.makeText(requireContext(), error, Toast.LENGTH_SHORT).show()
            if (errorCode == SignLandmarkerHelper.GPU_ERROR) {
//                fragmentCameraBinding.bottomSheetLayout.spinnerDelegate.setSelection(
//                    HandLandmarkerHelper.DELEGATE_CPU, false
//                )
            }
        }
    }

    // Update UI after hand have been detected. Extracts original
    // image height/width to scale and place the landmarks properly through
    // OverlayView
    override fun onHandResults(
        handResultBundle: SignLandmarkerHelper.HandResultBundle
    ) {
        handLandmarkerResults = handResultBundle.results.first()
        processIfReady()
        activity?.runOnUiThread {
            if (_fragmentCameraBinding != null) {
//                fragmentCameraBinding.bottomSheetLayout.inferenceTimeVal.text =
//                    String.format("%d ms", resultBundle.inferenceTime)

                // Pass necessary information to OverlayView for drawing on the canvas
                val handLandmarkerResults2 = handResultBundle.results.first()
                handLandmarkerResults2.handednesses()?.forEach {
                    it.forEach {
                        Log.d(
                            TAG,
                            "onResults handedNess: displayName ${it.displayName()}, index ${it.index()}, score ${it.score()}"
                        )
                    }
                }
                Log.d(
                    TAG,
                    "onResults landmark ${
                        handLandmarkerResults2.landmarks()
                        !!.map { it.map { "${it.x()},${it.y()},${it.z()}" }.joinToString(":") }
                            .joinToString("\n")
                    }"
                )
//                handLandmarkerResults.landmarks().forEach {
//                    it.forEach {
//                        it
//                    }
//                }

                fragmentCameraBinding.overlay.setHandResults(
                    handLandmarkerResults2,
                    handResultBundle.inputImageHeight,
                    handResultBundle.inputImageWidth,
                    RunningMode.LIVE_STREAM
                )

                // Force a redraw
                fragmentCameraBinding.overlay.invalidate()
            }

        }
    }

    // Update UI after hand have been detected. Extracts original
// image height/width to scale and place the landmarks properly through
// OverlayView
    override fun onPoseResults(
        poseResultBundle: SignLandmarkerHelper.PoseResultBundle
    ) {
        poseLandmarkerResult = poseResultBundle.results.first()
        processIfReady()
        activity?.runOnUiThread {
            if (_fragmentCameraBinding != null) {
//                fragmentCameraBinding.bottomSheetLayout.inferenceTimeVal.text =
//                    String.format("%d ms", resultBundle.inferenceTime)

                // Pass necessary information to OverlayView for drawing on the canvas

//                handLandmarkerResults.handednesses().forEach {
//                    it.forEach {
//                        Log.d(TAG, "onResults handedNess: displayName ${it.displayName()}, index ${it.index()}, score ${it.score()}")
//                    }
//                }
//                Log.d(TAG, "onResults landmark ${handLandmarkerResults.landmarks().map { it.map { "${it.x()},${it.y()},${it.z()}" }.joinToString(":") }.joinToString("\n")}")
//                handLandmarkerResults.landmarks().forEach {
//                    it.forEach {
//                        it
//                    }
//                }
                val poseLandmarkerResult2 = poseResultBundle.results.first()
                fragmentCameraBinding.overlay.setPoseResults(
                    poseLandmarkerResult2,
                    poseResultBundle.inputImageHeight,
                    poseResultBundle.inputImageWidth,
                    RunningMode.LIVE_STREAM
                )

                // Force a redraw
                fragmentCameraBinding.overlay.invalidate()
            }
        }
    }

    override fun onPoseError(error: String, errorCode: Int) {
        activity?.runOnUiThread {
            Toast.makeText(requireContext(), error, Toast.LENGTH_SHORT).show()
            if (errorCode == SignLandmarkerHelper.GPU_ERROR) {
//                fragmentCameraBinding.bottomSheetLayout.spinnerDelegate.setSelection(
//                    HandLandmarkerHelper.DELEGATE_CPU, false
//                )
            }
        }
    }

    private fun extractKeypoints(
        poseResults: PoseLandmarkerResult?,
        handResults: HandLandmarkerResult?
    ): FloatArray {
        val excludedIndices = (0..14)

        val pose = poseResults?.landmarks()
            ?.firstOrNull() // Get the first detected pose
            ?.mapIndexed { index, landmark ->
                if (index in excludedIndices)
                    listOf(
                        landmark.x(),
                        landmark.y(),
                        landmark.z(),
                        landmark.visibility().orElse(0f)
                    )
                else listOf(0f, 0f, 0f, 0f)
            }
            ?.flatten() ?: List((33) * 4) { 0f }

        // Left-hand landmarks (21 * 3)
        val lh = handResults?.landmarks()?.getOrNull(0)
            ?.map { listOf(it.x(), it.y(), it.z()) }
            ?.flatten() ?: List(21 * 3) { 0f }

        // Right-hand landmarks (21 * 3)
        val rh = handResults?.landmarks()?.getOrNull(1)
            ?.map { listOf(it.x(), it.y(), it.z()) }
            ?.flatten() ?: List(21 * 3) { 0f }
        return (pose + lh + rh).toFloatArray()
    }

    private fun normalizeLandmarks(
        landmarks: List<NormalizedLandmark>?,
        anchorIdx: Int, // Reference point (e.g., left hip or wrist)
        pointAIdx: Int, // First reference distance point
        pointBIdx: Int, // Second reference distance point
        includeVisibility: Boolean = false
    ): FloatArray {
        if (landmarks.isNullOrEmpty()) {
            return FloatArray(if (includeVisibility) 132 else 63) { 0f }
        }

        if (landmarks.size !in listOf(33, 21)) {
            return FloatArray(if (includeVisibility) 132 else 63) { 0f }
        }

        val anchor = landmarks[anchorIdx]
        val pointA = landmarks[pointAIdx]
        val pointB = landmarks[pointBIdx]
        val referenceDist = sqrt(
            (pointA.x() - pointB.x()).pow(2) +
                    (pointA.y() - pointB.y()).pow(2) +
                    (pointA.z() - pointB.z()).pow(2)
        )

        if (referenceDist < 1e-6) {
            return FloatArray(if (includeVisibility) 132 else 63) { 0f }
        }

        return landmarks.flatMap { landmark ->
            listOf(
                (landmark.x() - anchor.x()) / referenceDist,
                (landmark.y() - anchor.y()) / referenceDist,
                (landmark.z() - anchor.z()) / referenceDist
            ) + if (includeVisibility) listOf(landmark.visibility().orElse(0f)) else emptyList()
        }.toFloatArray()
    }


    private fun extractKeypoints3(
        poseResults: PoseLandmarkerResult?,
        handResults: HandLandmarkerResult?
    ): FloatArray {

        val pose = poseResults?.landmarks()?.firstOrNull()?.let {
            normalizeLandmarks(it, 23, 11, 12, includeVisibility = true)
        }?.takeIf { it.size == 132 } ?: FloatArray(132) { 0f }


        val lh = handResults?.landmarks()?.getOrNull(0)?.let {
            normalizeLandmarks(it, 0, 5, 17)
        }?.takeIf { it.size == 63 } ?: FloatArray(63) { 0f }


        val rh = handResults?.landmarks()?.getOrNull(1)?.let {
            normalizeLandmarks(it, 0, 5, 17)
        }?.takeIf { it.size == 63 } ?: FloatArray(63) { 0f }

        val result = (pose + lh + rh)


        require(result.size == 258) { "extractKeypoints() returned invalid size: ${result.size}, expected 258" }

        return result
    }



    private fun extractKeypoints2(
        poseResults: PoseLandmarkerResult?,
        handResults: HandLandmarkerResult?
    ): FloatArray {
        val excludedIndices = (0..14) // Exclude face landmarks

        // Reference point: Use mid-hip (average of left & right hips) if available
        val referencePoint = poseResults?.landmarks()
            ?.firstOrNull() // Get first detected pose
            ?.let { poseLandmarks ->
                val leftHip = poseLandmarks.getOrNull(23) // Left Hip
                val rightHip = poseLandmarks.getOrNull(24) // Right Hip
                if (leftHip != null && rightHip != null) {
                    listOf(
                        (leftHip.x() + rightHip.x()) / 2, // Mid-hip X
                        (leftHip.y() + rightHip.y()) / 2, // Mid-hip Y
                        (leftHip.z() + rightHip.z()) / 2  // Mid-hip Z
                    )
                } else {
                    listOf(0f, 0f, 0f) // Default if hips are missing
                }
            } ?: listOf(0f, 0f, 0f)

        fun normalizePose(landmarks: List<NormalizedLandmark>?, dimensions: Int): List<Float> {
            return landmarks?.mapIndexed { index, landmark ->
                if (index !in excludedIndices) {
                    listOf(
                        landmark.x() - referencePoint[0],
                        landmark.y() - referencePoint[1],
                        landmark.z() - referencePoint[2],
                        landmark.visibility().orElse(0f) // Include visibility
                    )
                } else {
                    listOf(0f, 0f, 0f, 0f) // Zero out excluded face landmarks
                }
            }?.flatten() ?: List(dimensions) { 0f }
        }

        fun normalizeHand(landmarks: List<NormalizedLandmark>?, dimensions: Int): List<Float> {
            return landmarks?.map {
                listOf(it.x() - referencePoint[0], it.y() - referencePoint[1], it.z() - referencePoint[2])
            }?.flatten() ?: List(dimensions) { 0f }
        }

        val pose = normalizePose(poseResults?.landmarks()?.firstOrNull(), 33 * 4)
        val lh = normalizeHand(handResults?.landmarks()?.getOrNull(0), 21 * 3)
        val rh = normalizeHand(handResults?.landmarks()?.getOrNull(1), 21 * 3)

        return (pose + lh + rh).toFloatArray()
    }


    private val inferenceScope = CoroutineScope(Dispatchers.Default)
    private var lastInferenceTime = 0L
    private val inferenceInterval = 500
    private val inferenceMutex = Mutex()

    private fun processIfReady() {
        if (poseLandmarkerResult == null || handLandmarkerResults == null) {
            return
        }

        val inputTensor = extractKeypoints3(poseLandmarkerResult, handLandmarkerResults)
//        if (!inputTensor.all { it == 0f }) {
//        }
        sequenceBuffer.addFrame(inputTensor)


        if (sequenceBuffer.isFull()) {
            inferenceScope.launch {
                inferenceMutex.withLock {
//                    Log.d(TAG, "sequenceBuffer.size: ${sequenceBuffer.}")

                    val inputSequence = sequenceBuffer.getFrames()
                    val inputSeqFloat = inputSequence.flatMap { it.toList() }.toFloatArray()

                    appendKeypointsToFile(requireContext(), inputSequence)
                    saveInputSequenceToFile(requireContext(), inputSeqFloat)


                    Log.d(
                        TAG,
                        "Running sign-language inference in background: ${
                            inputSequence.map { it }.joinToString(", ")
                        }"
                    )
                    val predictedSentence =
                        tfLiteModelHelper?.runInference(
                            requireContext(),
                            inputSeqFloat
                        )
                    withContext(Dispatchers.Main) {
                        fragmentCameraBinding.textView.text = predictedSentence
                    }


                }
            }
        }
    }

    // Normalization Function (In-place)
    fun normalizeLandmarks(landmarks: FloatArray, epsilon: Float = 1e-6f): FloatArray {
        val numPoints = landmarks.size / 3
        val reshaped = landmarks.toList().chunked(3).map { it.toFloatArray() }

        if (numPoints == 33) { // Pose
            val anchor = reshaped[23] // Left hip
            val referenceDist = reshaped[11].zip(reshaped[12]) { a, b -> a - b }
                .map { it * it }
                .sum()
                .let { kotlin.math.sqrt(it) }

            if (referenceDist < epsilon) return FloatArray(landmarks.size) { 0f }

            return reshaped.map { point ->
                point.zip(anchor) { p, a -> (p - a) / referenceDist }.toFloatArray()
            }.flatMap { it.toList() }.toFloatArray()

        } else if (numPoints == 21) { // Hands
            val anchor = reshaped[0] // Wrist
            val referenceDist = reshaped[5].zip(reshaped[17]) { a, b -> a - b }
                .map { it * it }
                .sum()
                .let { kotlin.math.sqrt(it) }

            if (referenceDist < epsilon) return FloatArray(landmarks.size) { 0f }

            return reshaped.map { point ->
                point.zip(anchor) { p, a -> (p - a) / referenceDist }.toFloatArray()
            }.flatMap { it.toList() }.toFloatArray()
        }

        return landmarks // Return unchanged if unexpected format
    }


    fun reshapeInput(input: FloatArray, dim1: Int, dim2: Int, dim3: Int): Array<Array<FloatArray>> {
        require(input.size == dim1 * dim2 * dim3) { "Invalid reshape dimensions" }

        val reshaped = Array(dim1) { Array(dim2) { FloatArray(dim3) } }

        var index = 0
        for (i in 0 until dim1) {
            for (j in 0 until dim2) {
                for (k in 0 until dim3) {
                    reshaped[i][j][k] = input[index++]
                }
            }
        }
        return reshaped
    }


    //    private val sequenceBuffer = ArrayDeque<FloatArray>(CAPACITY)
    private val sequenceBuffer = FrameBuffer(CAPACITY)

    private fun updateBuffer(newKeypoints: FloatArray) {
        sequenceBuffer.addFrame(newKeypoints)
    }

    private fun appendKeypointsToFile(
        context: Context,
        inputSequence: Array<FloatArray>
    ) {
        val fileName = "keypoints.json"
        val file = File(context.getExternalFilesDir(null), fileName)

        try {
            val jsonArray: JSONArray = if (file.exists()) {
                // Load existing data
                val content = file.readText()
                JSONArray(content) // Read JSON as an array
            } else {
                JSONArray()
            }

            // Convert inputSequence to JSONArray and append to existing list
            jsonArray.put(JSONArray(inputSequence.toList()))

            // Write updated JSON back to file
            file.writeText(jsonArray.toString(4)) // 4 = indentation for readability

            Log.d(TAG, "Appended inputSequence to '$fileName' at: ${file.absolutePath}")

        } catch (e: Exception) {
            Log.e(TAG, "Failed to append keypoints", e)
        }
    }

    private fun saveInputSequenceToFile(
        context: Context,
        inputSequence: FloatArray
    ) {
        val fileName = "keypoints_float.json"
        val file = File(context.getExternalFilesDir(null), fileName)

        try {
            val jsonArray: JSONArray = if (file.exists()) {
                // Load existing data
                val content = file.readText()
                JSONArray(content) // Read JSON as an array
            } else {
                JSONArray()
            }

            // Convert inputSequence to JSONArray and append to existing list
            jsonArray.put(JSONArray(inputSequence.toList()))

            // Write updated JSON back to file
            file.writeText(jsonArray.toString(4)) // 4 = indentation for readability

            Log.d(TAG, "Appended inputSequence to '$fileName' at: ${file.absolutePath}")

        } catch (e: Exception) {
            Log.e(TAG, "Failed to append keypoints", e)
        }
    }

}
