package prcj.common

import org.json.*
import java.io.*
import java.util.zip.*
import javax.servlet.*

object Util {
    fun readStreamStr(istream: InputStream): String? {
        val bytes = readStream(istream) ?: return null
        return String(bytes)
    }

    fun readStream(istream: InputStream): ByteArray {
        val os = ByteArrayOutputStream()
        istream.use { it.copyTo(os) }
        return os.toByteArray()
    }

    fun readCompressedStream(iStream: InputStream): ByteArray? {
        val gzipStream = GZIPInputStream(iStream)
        return readStream(gzipStream)
    }

    fun compressBytes(inBytes: ByteArray): ByteArray? {
        val os = ByteArrayOutputStream()
        val gzipOS = GZIPOutputStream(os)
        gzipOS.write(inBytes)
        gzipOS.finish()
        gzipOS.close()
        val outBytes = os.toByteArray()
        if (outBytes.size >= inBytes.size) return null
        return outBytes
    }

    fun createFile(path: String, data: String) {
        val bytes = data.toByteArray()
        return createFile(path, bytes)
    }

    private fun createFile(path: String, bytes: ByteArray) {
        val file = File(path)
        val folder = file.parentFile
        folder.mkdirs()
        file.writeBytes(bytes)
    }

    fun exceptionToString(ex: Throwable): String {
        val sw = StringWriter()
        ex.printStackTrace(PrintWriter(sw))
        return sw.toString()
    }

    fun readConfig(context: ServletContext): JSONObject? {
        val istream = context.getResourceAsStream("/config.json")
        val jsonStr = readStreamStr(istream)
        return JSONObject(jsonStr!!)
    }

    fun log(msg: String) {
        try {
            File("logs").mkdirs()
            val loWriter = FileWriter("logs\\AppServerLog.txt", true)
            loWriter.write(msg + "\r\n")
            loWriter.close()
        } catch (ex: Throwable) {
            println(ex.message)
        }
    }

    fun log(ex: Throwable) {
        log(exceptionToString(ex))
    }

    fun getMap(entry: HashMap<String, Any>, key: String): HashMap<String, Any>? {
        return entry[key] as HashMap<String, Any>?
    }

    fun getStr(entry: HashMap<String, Any>, key: String): String? {
        return entry[key] as String?
    }

    fun getString(entry: HashMap<String, Any>, key: String): String {
        return entry[key] as String
    }

    fun getLong(entry: HashMap<String, Any>, key: String): Long {
        return when (val obj = entry[key]) {
            null -> 0
            is Long -> obj
            is Int -> obj.toLong()
            else -> {
                log("Util.getLong Invalid type " + obj.javaClass)
                -1
            }
        }
    }

    fun getInt(entry: HashMap<String, Any>, key: String): Int {
        return when (val obj = entry[key]) {
            null -> 0
            is Long -> obj.toInt()
            is Int -> obj
            else -> {
                log("Util.getInt Invalid type " + obj.javaClass)
                -1
            }
        }
    }

    fun getBool(entry: HashMap<String, Any>, key: String): Boolean {
        val vl = entry[key] as Boolean?
        return vl ?: false
    }
}
