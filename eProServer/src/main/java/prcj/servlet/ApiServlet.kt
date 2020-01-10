package prcj.servlet

import org.json.*
import prcj.common.*
import java.io.*
import javax.servlet.*
import javax.servlet.annotation.*
import javax.servlet.http.*

@WebServlet("/api/*")
open class ApiServlet : HttpServlet() {
    fun allowCORS(response: HttpServletResponse) {
        response.setHeader("Access-Control-Allow-Origin", "*")
        response.setHeader("Access-Control-Allow-Credentials", "true")
    }

    @Throws(ServletException::class, IOException::class)
    override fun doGet(request: HttpServletRequest, response: HttpServletResponse) {
        process(request, response)
    }

    @Throws(ServletException::class, IOException::class)
    override fun doPost(request: HttpServletRequest, response: HttpServletResponse) {
        process(request, response)
    }

    fun process(request: HttpServletRequest, response: HttpServletResponse) {
        try {
            val bytes = Util.readStream(request.inputStream)
            val jsonStr = String(bytes)
            val json = JSONObject(JSONTokener(jsonStr))
            val map = json.toMap();
            val apiName: String = request.getParameter("apiName")
            val methodName = request.getParameter("methodName") ?: "process"
            val api: BaseApi = Class.forName("prcj.api.$apiName").newInstance() as BaseApi
            api.request = request
            api.response = response
            val rslt = api.start(methodName, map)
            sendResult(response, rslt)
        } catch (ex: Throwable) {
            val rslt = Rslt.ex(ex)
            sendResult(response, rslt)
        }
    }

    private fun sendResult(response: HttpServletResponse, rslt: Rslt) {
        val map = rslt.toMap()
        val json = JSONObject(map)
        val jsonStr = json.toString()
        val os = response.outputStream
        var len = 0
        for (b in jsonStr.toByteArray()) {
            os.write(b.toInt() and 0xff)
            len++
        }
        if (!response.isCommitted) response.setHeader("Content-Length", len.toString())
        os.close()
    }
}
