package com.gitfox.tomanova

import android.os.Bundle
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL

class MainActivity : AppCompatActivity() {

    private lateinit var webView: WebView
    private var serverProcess: Process? = null
    private val port = 18423

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        webView = findViewById(R.id.webview)
        val settings = webView.settings
        settings.javaScriptEnabled = true
        settings.domStorageEnabled = true
        settings.allowFileAccess = true
        settings.allowContentAccess = true
        settings.setSupportMultipleWindows(false)
        settings.mediaPlaybackRequiresUserGesture = false
        settings.loadWithOverviewMode = true
        settings.useWideViewPort = true
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW)

        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean = false
        }

        Thread {
            try {
                val binDir = File(filesDir, "bin")
                binDir.mkdirs()
                val bin = extractBinary("tomato-novel-downloader", File(binDir, "tomanova"))

                val dataDir = File(filesDir, "data").absolutePath
                File(dataDir).mkdirs()

                val proc = ProcessBuilder(bin.absolutePath, "--server", "--data-dir", dataDir)
                    .directory(dataDir)
                    .redirectErrorStream(true)
                    .environment()
                    .apply { put("TOMATO_WEB_ADDR", "127.0.0.1:$port") }
                    .start()
                serverProcess = proc

                waitForHttp(port, 45)

                runOnUiThread {
                    webView.loadUrl("http://127.0.0.1:$port/")
                }
            } catch (e: Exception) {
                showError("Server failed: ${e.message}\n${e.stackTraceToString()}")
            }
        }.start()
    }

    private fun extractBinary(assetsName: String, dest: File): File {
        if (dest.exists() && dest.length() > 0) return dest
        assets.open(assetsName).use { input ->
            FileOutputStream(dest).use { out -> input.copyTo(out) }
        }
        dest.setExecutable(true, false)
        dest.setReadable(true, false)
        dest.setWritable(true, false)
        return dest
    }

    private fun waitForHttp(port: Int, maxSec: Int): Boolean {
        val deadline = System.currentTimeMillis() + maxSec * 1000L
        while (System.currentTimeMillis() < deadline) {
            try {
                val conn = URL("http://127.0.0.1:$port/").openConnection() as HttpURLConnection
                conn.connectTimeout = 1000
                conn.readTimeout = 1000
                conn.requestMethod = "HEAD"
                val code = conn.responseCode
                conn.disconnect()
                if (code in 200..499) return true
            } catch (_: Exception) {}
            Thread.sleep(500)
        }
        return false
    }

    private fun showError(msg: String) {
        runOnUiThread {
            webView.loadDataWithBaseURL(
                null,
                "<html><body style='font-family:sans-serif;padding:24px'>"
                    + "<h2>Tomanova</h2>"
                    + "<pre style='color:#c00;font-size:12px'>$msg</pre>"
                    + "</body></html>",
                "text/html", "utf-8", null
            )
        }
    }

    override fun onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack()
        } else {
            super.onBackPressed()
        }
    }

    override fun onDestroy() {
        serverProcess?.destroy()
        try { serverProcess?.waitFor(2, java.util.concurrent.TimeUnit.SECONDS) } catch (_: Exception) {}
        super.onDestroy()
    }
}
