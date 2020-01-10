package prcj.common

import java.sql.*
import java.util.*

object DBUtil {
    fun retrieveSingle(stmt: PreparedStatement): Array<Any?>? {
        val rows = retrieve(stmt)
        if (rows.size == 0) return null
        return rows[0]
    }

    fun retrieve(stmt: PreparedStatement): ArrayList<Array<Any?>> {
        val rs = stmt.executeQuery()
        val metaData = rs.metaData
        val columnCount = metaData.columnCount

        val rows = ArrayList<Array<Any?>>()
        while (rs.next()) {
            val row = arrayOfNulls<Any?>(columnCount)
            rows.add(row)
            for (j in 0 until columnCount) {
                row[j] = rs.getObject(j + 1)
            }
        }
        rs.close()
        stmt.close()
        return rows
    }

}