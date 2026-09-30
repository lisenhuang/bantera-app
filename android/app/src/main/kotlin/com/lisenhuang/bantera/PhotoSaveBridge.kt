package com.lisenhuang.bantera

import android.Manifest
import android.app.Activity
import android.content.ContentValues
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.util.UUID

class PhotoSaveBridge(private val activity: Activity, messenger: BinaryMessenger) {
    private val permissionRequest = 4813
    private var pending: Pair<ByteArray, MethodChannel.Result>? = null

    init {
        MethodChannel(messenger, "bantera/photos").setMethodCallHandler { call, result ->
            if (call.method != "saveImage") {
                result.notImplemented()
            } else {
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes == null || bytes.isEmpty() || bytes.size > 20_000_000) {
                    result.error("invalid_image", "Invalid progress image.", null)
                } else if (Build.VERSION.SDK_INT < 29 &&
                    ContextCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                    if (pending != null) result.error("busy", "Photo permission is pending.", null)
                    else {
                        pending = Pair(bytes, result)
                        ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), permissionRequest)
                    }
                } else save(bytes, result)
            }
        }
    }

    fun permissionResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode != permissionRequest) return
        val request = pending ?: return
        pending = null
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) save(request.first, request.second)
        else request.second.error("permission_denied", "Allow saving photos in Settings.", null)
    }

    private fun save(bytes: ByteArray, result: MethodChannel.Result) {
        Thread {
            try {
                val jpeg = bytes.size >= 2 && (bytes[0].toInt() and 255) == 255 && (bytes[1].toInt() and 255) == 216
                val mimeType = if (jpeg) "image/jpeg" else "image/png"
                val extension = if (jpeg) "jpg" else "png"
                val name = "bantera-word-progress-${UUID.randomUUID()}.$extension"
                if (Build.VERSION.SDK_INT >= 29) {
                    val resolver = activity.contentResolver
                    val values = ContentValues().apply {
                        put(MediaStore.Images.Media.DISPLAY_NAME, name)
                        put(MediaStore.Images.Media.MIME_TYPE, mimeType)
                        put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Bantera")
                        put(MediaStore.Images.Media.IS_PENDING, 1)
                    }
                    val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                        ?: throw IOException("Could not create photo")
                    try {
                        val stream = resolver.openOutputStream(uri) ?: throw IOException("Could not write photo")
                        stream.use { it.write(bytes) }
                        val published = resolver.update(uri, ContentValues().apply {
                            put(MediaStore.Images.Media.IS_PENDING, 0)
                        }, null, null)
                        if (published == 0) throw IOException("Could not publish photo")
                    } catch (error: Exception) {
                        resolver.delete(uri, null, null)
                        throw error
                    }
                    activity.runOnUiThread { result.success(null) }
                } else {
                    @Suppress("DEPRECATION")
                    val directory = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "Bantera")
                    if (!directory.exists() && !directory.mkdirs()) throw IOException("Could not create photo directory")
                    val file = File(directory, name)
                    try { file.writeBytes(bytes) } catch (error: Exception) { file.delete(); throw error }
                    MediaScannerConnection.scanFile(activity, arrayOf(file.path), arrayOf(mimeType)) { _, uri ->
                        activity.runOnUiThread {
                            if (uri != null) result.success(null)
                            else result.error("save_failed", "Photo could not be indexed.", null)
                        }
                    }
                }
            } catch (error: Exception) {
                activity.runOnUiThread { result.error("save_failed", error.message, null) }
            }
        }.start()
    }
}
