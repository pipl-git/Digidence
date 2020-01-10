package prcj.common

class Rslt {
    var rc = Integer.MAX_VALUE
    var msg: String? = null
    var data: Any? = null

    constructor(rc: Int, msg: String?) {
        this.rc = rc
        this.msg = msg
    }

    constructor(rc: Int, msg: String?, data: Any?) {
        this.rc = rc
        this.msg = msg
        this.data = data
    }

    fun toMap(): HashMap<String, Any?> {
        val map = HashMap<String, Any?>()
        map["rc"] = rc
        if (msg != null) map["msg"] = msg
        if (data != null) map["data"] = data
        return map
    }

    companion object {

        fun ok(): Rslt {
            return Rslt(0, null, null)
        }


        fun ok(data: Any?): Rslt {
            return Rslt(0, null, data)
        }


        fun ex(ex: Throwable): Rslt {
            return Rslt(-2, Util.exceptionToString(ex))
        }


        fun err(err: String?): Rslt {
            return Rslt(-1, err, null)
        }
    }
}
