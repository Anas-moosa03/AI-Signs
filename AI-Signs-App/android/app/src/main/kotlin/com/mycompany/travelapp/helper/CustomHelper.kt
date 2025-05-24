package com.mycompany.travelapp.helper

import android.content.Context
import java.io.IOException

fun loadTaskFile(context: Context, assetFileName: String): ByteArray? {
    return try {
        context.assets.open(assetFileName).use { inputStream ->
            inputStream.readBytes()
        }
    } catch (e: IOException) {
        e.printStackTrace()
        null
    }
}
