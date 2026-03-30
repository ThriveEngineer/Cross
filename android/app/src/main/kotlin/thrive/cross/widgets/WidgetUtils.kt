package thrive.cross.widgets

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import org.json.JSONArray
import org.json.JSONObject

/// Shared action callback that stores a deep link URI in SharedPreferences
/// and launches the main activity. Used by folder widgets to navigate to
/// a specific folder when tapped.
class LaunchAppAction : ActionCallback {
    companion object {
        val uriKey = ActionParameters.Key<String>("uri")
    }

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val uriStr = parameters[uriKey] ?: return

        // Store the pending deep link so Flutter can read it on resume
        val prefs = context.getSharedPreferences(
            "HomeWidgetPreferences", Context.MODE_PRIVATE
        )
        prefs.edit().putString("widget_pending_deep_link", uriStr).apply()

        // Launch the main activity
        val intent = Intent(context, thrive.cross.MainActivity::class.java).apply {
            action = "es.antonborri.home_widget.action.LAUNCH"
            data = Uri.parse(uriStr)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }
}

data class WidgetTask(
    val index: Int,
    val name: String,
    val completed: Boolean,
    val folder: String,
    val date: String? = null
)

fun parseTasks(json: String?): List<WidgetTask> {
    if (json.isNullOrEmpty()) return emptyList()
    return try {
        val arr = JSONArray(json)
        (0 until arr.length()).map { i ->
            val obj = arr.getJSONObject(i)
            WidgetTask(
                index = obj.getInt("i"),
                name = obj.getString("n"),
                completed = obj.getBoolean("c"),
                folder = obj.getString("f"),
                date = if (obj.has("d") && !obj.isNull("d")) obj.getString("d") else null
            )
        }
    } catch (e: Exception) {
        emptyList()
    }
}

fun parseFolders(json: String?): List<String> {
    if (json.isNullOrEmpty()) return emptyList()
    return try {
        val arr = JSONArray(json)
        (0 until arr.length()).map { arr.getString(it) }
    } catch (e: Exception) {
        emptyList()
    }
}
