package prcj.common

import org.apache.tomcat.jdbc.pool.*

import java.sql.*
import javax.servlet.*

object ConnectionPool {
    private var dataSource: DataSource? = null

    fun getConnection(servletContext: ServletContext, secondTry: Boolean = false): Connection {
        try {
            getDataSource(servletContext)
            val con = dataSource!!.connection
            if (con.isClosed) throw Error("Connection is closed")

            if (!con.isValid(0)) {
                Util.log("Connection is invalid")
                con.close()
                if (secondTry) throw Error("Connection is invalid")
                dataSource = null
                return getConnection(servletContext, true)
            }
            return con
        } catch (ex: Exception) {
            throw Error(ex)
        }
    }

    fun getDataSource(servletContext: ServletContext): DataSource {
        if (dataSource == null) {
            val jsonObj = Util.readConfig(servletContext)
            val params = jsonObj!!.getJSONObject("db_params")
            dataSource = DataSource()
            dataSource!!.driverClassName = params.getString("driverClassName")
            dataSource!!.url = params.getString("url")
            dataSource!!.username = params.getString("username")
            dataSource!!.password = params.getString("password")
            dataSource!!.initialSize = params.getInt("initialSize")
            dataSource!!.maxIdle = params.getInt("maxIdle")
            dataSource!!.maxActive = params.getInt("maxActive")
        }
        return dataSource as DataSource
    }

    fun releaseConnection(con: Connection) {
        try {
            Util.log("Release connection")
            con.close()
        } catch (ex: Exception) {
            throw Error(ex)
        }

    }
}
