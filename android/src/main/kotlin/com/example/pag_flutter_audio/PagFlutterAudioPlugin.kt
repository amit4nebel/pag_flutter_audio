package com.example.pag_flutter_audio

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.libpag.PAGFile
import java.nio.ByteBuffer

class PagFlutterAudioPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pag_flutter_audio")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "extractAudio" -> {
                val pagBytes = call.argument<ByteArray>("pagBytes")
                if (pagBytes != null) {
                    val audioData = extractAudioFromPAG(pagBytes)
                    result.success(audioData)
                } else {
                    result.error("INVALID_ARGS", "pagBytes is required", null)
                }
            }
            "getAudioInfo" -> {
                val pagBytes = call.argument<ByteArray>("pagBytes")
                if (pagBytes != null) {
                    val info = getAudioInfo(pagBytes)
                    result.success(info)
                } else {
                    result.error("INVALID_ARGS", "pagBytes is required", null)
                }
            }
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun extractAudioFromPAG(pagBytes: ByteArray): ByteArray? {
        return try {
            val pagFile = PAGFile.Load(pagBytes) ?: return null
            val audioBuffer: ByteBuffer? = pagFile.audioBytes()
            val audioBytes = bufferToByteArray(audioBuffer)
            audioBytes
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun bufferToByteArray(buffer: ByteBuffer?): ByteArray? {
        if (buffer == null) return null
        val bytes = ByteArray(buffer.remaining())
        buffer.get(bytes)
        return bytes
    }

    private fun getAudioInfo(pagBytes: ByteArray): Map<String, Any?> {
        return try {
            val pagFile = PAGFile.Load(pagBytes) ?: return mapOf(
                "hasAudio" to false,
                "audioBytes" to null,
                "audioStartTime" to 0L,
                "duration" to 0L
            )

            val audioBuffer: ByteBuffer? = pagFile.audioBytes()
            val audioBytes = bufferToByteArray(audioBuffer)
            val audioStartTime = pagFile.audioStartTime()
            val duration = pagFile.duration()

            mapOf(
                "hasAudio" to (audioBytes != null && audioBytes.isNotEmpty()),
                "audioBytes" to audioBytes,
                "audioStartTime" to audioStartTime,
                "duration" to duration
            )
        } catch (e: Exception) {
            e.printStackTrace()
            mapOf(
                "hasAudio" to false,
                "audioBytes" to null,
                "audioStartTime" to 0L,
                "duration" to 0L
            )
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
