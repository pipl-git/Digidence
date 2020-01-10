package prcj.api

import prcj.common.*
import java.text.*


class AppsCommon : BaseApi {

    constructor() {
        register(::login)
        register(::insertCheckIn)
        register(::retrieveCheckIn)
        register(::registerUser)
    }

    private fun login(rqst: Any?): Rslt {
        val rq = rqst as HashMap<String, Any>
        val email = Util.getStr(rq, "email")
        val password = Util.getStr(rq, "password")
        val sql = "Select id, password From usr Where email = ?"
        val stmt = dbCon.prepareStatement(sql)
        stmt.setString(1, email)
        val row = DBUtil.retrieveSingle(stmt) ?: return Rslt.err("eMail or Password is invalid")
        val pwd = row[1] as String;
        if (password != pwd) return Rslt.err("eMail or Password is invalid")
        val id = row[0]
        return Rslt.ok(id)
    }

    private fun registerUser(rqst: Any?): Rslt {
        val rq = rqst as HashMap<String, Any>
        val email = Util.getStr(rq, "email")
        val password = Util.getStr(rq, "password")

        var sql = "Select id From usr Where email = ?"
        var stmt = dbCon.prepareStatement(sql)
        stmt.setString(1, email)
        val row = DBUtil.retrieveSingle(stmt)
        if (row != null) return Rslt.err("$email is already registered");

        sql = "Insert Into usr(email, password) Values(?, ?)"
        stmt = dbCon.prepareStatement(sql)
        stmt.setString(1, email)
        stmt.setString(2, password)
        stmt.executeUpdate()
        return Rslt.ok()
    }

    private fun retrieveCheckIn(rqst: Any?): Rslt {
        val rq = rqst as HashMap<String, Any>
        val format = SimpleDateFormat("yyyyMMdd")
        val usr_id = Util.getInt(rq, "usr_id")
        val dtStr = Util.getString(rq, "dt")
        val dt = java.sql.Date(format.parse(dtStr).time)
        val sql =
            "Select activity, attention, swelling_1, swelling_2, swelling_3, other, pain From check_in Where usr_id = ? And dt = ?"
        val stmt = dbCon.prepareStatement(sql)
        stmt.setInt(1, usr_id)
        stmt.setDate(2, dt)
        val row = DBUtil.retrieveSingle(stmt) ?: return Rslt.ok()

        val data = HashMap<String, Any>()
        if (row[0] != null) data["activity"] = row[0]!!
        if (row[1] != null) data["attention"] = row[1]!!
        if (row[2] != null) data["swelling_1"] = row[2]!!
        if (row[3] != null) data["swelling_2"] = row[3]!!
        if (row[4] != null) data["swelling_3"] = row[4]!!
        if (row[5] != null) data["other"] = row[5]!!
        if (row[6] != null) data["pain"] = row[6]!!
        return Rslt.ok(data)
    }

    private fun insertCheckIn(rqst: Any?): Rslt {
        val rq = rqst as HashMap<String, Any>
        val format = SimpleDateFormat("yyyyMMdd")
        val usr_id = Util.getInt(rq, "usr_id")
        val dtStr = Util.getString(rq, "dt")
        val dt = java.sql.Date(format.parse(dtStr).time)
        val activity = Util.getInt(rq, "activity")
        val attention = Util.getInt(rq, "attention")
        val swelling_1 = Util.getInt(rq, "swelling_1")
        val swelling_2 = Util.getInt(rq, "swelling_2")
        val swelling_3 = Util.getInt(rq, "swelling_3")
        val other = Util.getStr(rq, "other")
        val pain = Util.getInt(rq, "pain")

        val delSQL = "Delete From check_in Where usr_id = ? And  dt = ?"
        var stmt = dbCon.prepareStatement(delSQL)
        stmt.setInt(1, usr_id)
        stmt.setDate(2, dt)
        stmt.executeUpdate()

        val sql =
            "Insert Into check_in(usr_id, dt, activity, attention, swelling_1, swelling_2, swelling_3, other, pain) Values(?, ?, ?, ?, ?, ?, ?, ?, ?)"
        stmt = dbCon.prepareStatement(sql)
        stmt.setInt(1, usr_id)
        stmt.setDate(2, dt)
        if (activity > 0) stmt.setInt(3, activity) else stmt.setNull(3, java.sql.Types.INTEGER)
        if (attention > 0) stmt.setInt(4, attention) else stmt.setNull(4, java.sql.Types.INTEGER)
        if (swelling_1 > 0) stmt.setInt(5, swelling_1) else stmt.setNull(5, java.sql.Types.INTEGER)
        if (swelling_2 > 0) stmt.setInt(6, swelling_2) else stmt.setNull(6, java.sql.Types.INTEGER)
        if (swelling_3 > 0) stmt.setInt(7, swelling_3) else stmt.setNull(7, java.sql.Types.INTEGER)
        stmt.setString(8, other)
        if (pain > 0) stmt.setInt(9, pain) else stmt.setNull(9, java.sql.Types.INTEGER)
        stmt.executeUpdate()
        return Rslt.ok()
    }
}
