package prcj.common

import java.sql.*
import java.util.*
import javax.servlet.http.*
import kotlin.jvm.internal.*

open class BaseApi {
    lateinit var request: HttpServletRequest
    lateinit var response: HttpServletResponse
    lateinit var _dbCon: Connection
    private var methods = HashMap<String, (Any?) -> Rslt>()

    fun register(method: (Any?) -> Rslt) {
        val name = (method as CallableReference).name
        methods[name] = method
    }

    fun start(methodName: String, rqst: Any?): Rslt {
        try {
            val method = methods[methodName] ?: return handleMethod(methodName, rqst)
            val rslt = method(rqst)
            cleanUp(rslt.rc)
            return rslt
        } catch (ex: Throwable) {
            cleanUp(-1)
            return Rslt.ex(ex)
        }
    }

    open fun process(rqst: Any?): Rslt {
        return Rslt.err("Process method not implemented in " + this.javaClass.name)
    }

    open fun handleMethod(methodName: String, rqst: Any?): Rslt {
        return Rslt.err("Method " + methodName + " not registered in " + this.javaClass.name)
    }

    open fun log(msg: String?) {
        Util.log("${this.javaClass.name} $msg\r\n")
    }

    open fun log(ex: Throwable) {
        Util.log("${this.javaClass.name} Exception\r\n")
        Util.log(ex)
    }

    val dbCon: Connection
        get() {
            if (::_dbCon.isInitialized && !_dbCon.isClosed) return _dbCon
            _dbCon = ConnectionPool.getConnection(request.servletContext)
            _dbCon.autoCommit = false
            return _dbCon
        }

    fun cleanUp(rc: Int) {
        if (!::_dbCon.isInitialized) return
        if (rc == 0) {
            dbCon.commit()
        } else {
            dbCon.rollback()
        }
        ConnectionPool.releaseConnection(_dbCon)
    }
}
