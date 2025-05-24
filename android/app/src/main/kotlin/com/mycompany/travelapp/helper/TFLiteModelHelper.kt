import android.content.Context
import android.content.res.AssetFileDescriptor
import android.os.Environment
import android.util.Log
import com.mycompany.travelapp.mediapipe.CameraFragment
import com.mycompany.travelapp.mediapipe.CameraFragment.Companion
import org.json.JSONArray
import org.json.JSONObject
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.common.FileUtil
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel


class TFLiteModelHelper(context: Context) {
    companion object {
        val TAG = "TFLiteModelHelper"
    }

    private var interpreter: Interpreter? = null

    // Define action labels
    private val actions = arrayOf(
        "null", "besm allah", "alsalam alekom", "alekom salam", "aslan w shlan", "me",
        "age", "alhamdulilah", "bad", "how are you", "friend",
        "good", "happy", "you", "my name is", "no",
        "or", "taaban", "what", "where", "yes",
        "look", "said", "walking", "did not hear", "remind me",
        "eat", "bayt", "hospital", "run", "sleep",
        "think", "tomorrow", "yesterday", "today", "when",
        "dhuhr", "sabah", "university", "kuliyah", "night",
        "a3ooth bellah", "danger", "enough", "hot", "mosque", "surprise", "tard",
        "big", "clean", "dirty", "fire", "give me", "sho dakhalak", "small",
        "help", "same", "hour", "important", "ok", "please", "want",
        "riyadah", "sallah", "telephone", "hamam", "water", "eid"
    )

    // Store previous words for sentence construction
    private val sentenceBuilder = StringBuilder()
    private var lastWord: String? = null

    init {
        loadModel(context)
    }

    private fun loadModel(context: Context) {
        val model: MappedByteBuffer = FileUtil.loadMappedFile(context, "action_normed.tflite")
        val options = Interpreter.Options()
        options.numThreads = 1
        interpreter = Interpreter(model, options)
    }

    fun clearSentence() {
        sentenceBuilder.clear()
        lastWord = null
    }

    fun runInference(context: Context, inputData: FloatArray): String {
        // Ensure inputData has expected size
//        Log.d(TAG, "Input size: ${inputData.size}, Expected: ${45 * 258}")
//        if (inputData.size != 45 * 258) {
//            Log.e(TAG, "Invalid input data size: Expected ${45 * 258}, got ${inputData.size}")
//            return sentenceBuilder.toString()
//        }

        // Allocate ByteBuffer once (if reusing, store it in a class variable)
        val inputBuffer = ByteBuffer.allocateDirect(4 * inputData.size)
            .order(ByteOrder.nativeOrder())

        // Fill buffer
        inputBuffer.rewind() // Ensure correct positioning before filling
//        inputData.forEach { frame ->
//            frame.forEach {
//                inputBuffer.putFloat(it)
//            }
//        }
        inputData.forEach { inputBuffer.putFloat(it) }

        // Prepare output buffer (assuming model outputs a 1x68 array)
        val outputBuffer = Array(1) { FloatArray(68) }

        // Run inference only if interpreter is initialized
        interpreter?.let {
            it.run(inputBuffer, outputBuffer)
        } ?: run {
            Log.e(TAG, "TFLite Interpreter is null")
            return sentenceBuilder.toString()
        }

        // Get predicted index with the highest probability
        val predictedIndex = outputBuffer[0].indices.maxByOrNull { outputBuffer[0][it] }
            ?: return sentenceBuilder.toString()

        // Ensure actions list is valid
        if (predictedIndex >= actions.size) {
            Log.e(TAG, "Predicted index out of bounds: $predictedIndex")
            return sentenceBuilder.toString()
        }

        val predictedWord = actions[predictedIndex]

        // Avoid repeating the same word consecutively
        if (predictedWord != "null" && predictedWord != lastWord) {
            if (sentenceBuilder.isNotEmpty()) {
                sentenceBuilder.append(" ") // Add space between words
            }
            sentenceBuilder.append(predictedWord)
            lastWord = predictedWord

            saveInputSequenceToFile(context, predictedWord, inputData)
            Log.d(
                TAG,
                "Result text: $predictedWord, points: ${inputData.map { "$it" }.joinToString(", ")}"
            )
        }

        return sentenceBuilder.toString()
    }

    private fun saveInputSequenceToFile(
        context: Context,
        predictedWord: String,
        inputSequence: FloatArray
    ) {
        val fileName = "input_sequence.json"
        val file = File(context.getExternalFilesDir(null), fileName)


        try {
            val jsonData: JSONObject = if (file.exists()) {
                // Load existing data if the file exists
                val content = file.readText()
                JSONObject(content)
            } else {
                JSONObject()
            }

            // Convert inputSequence to JSONArray
            val inputArray = JSONArray(inputSequence.toList())

            // Append new entry
            jsonData.put(predictedWord, inputArray)

            // Write updated JSON back to file
            file.writeText(jsonData.toString(4)) // 4 = indentation for readability

            Log.d(TAG, "Appended inputSequence under key '$predictedWord' to: ${file.absolutePath}")

        } catch (e: Exception) {
            Log.e(TAG, "Failed to append inputSequence", e)
        }
    }

}
