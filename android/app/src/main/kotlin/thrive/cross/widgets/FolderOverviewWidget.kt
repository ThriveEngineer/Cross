package thrive.cross.widgets

import thrive.cross.R
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

class FolderOverviewWidget : GlanceAppWidget() {

    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent { Content(context, currentState()) }
    }

    @Composable
    private fun Content(context: Context, state: HomeWidgetGlanceState) {
        val prefs = state.preferences
        val isPro = prefs.getString("widget_is_pro", "") == "true"
        val tasks = parseTasks(prefs.getString("widget_tasks", null))
        val folders = parseFolders(prefs.getString("widget_folders", null))

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(Color.White)
                .padding(top = 16.dp, start = 16.dp, end = 16.dp, bottom = 8.dp)
        ) {
            // Header
            Text(
                text = "Folders",
                style = TextStyle(
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = ColorProvider(Color(0xFF1D1D1D))
                )
            )

            Spacer(modifier = GlanceModifier.height(10.dp))

            // Thin divider
            Box(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .height(0.5.dp)
                    .background(Color(0xFFE0E0E0))
            ) {}

            Spacer(modifier = GlanceModifier.height(4.dp))

            if (!isPro) {
                Box(
                    modifier = GlanceModifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "Upgrade to Cross Pro",
                            style = TextStyle(
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Medium,
                                color = ColorProvider(Color(0xFF1D1D1D))
                            )
                        )
                        Spacer(modifier = GlanceModifier.height(4.dp))
                        Text(
                            text = "Unlock home screen widgets",
                            style = TextStyle(
                                fontSize = 13.sp,
                                color = ColorProvider(Color(0xFF808080))
                            )
                        )
                    }
                }
            } else if (folders.isEmpty()) {
                Box(
                    modifier = GlanceModifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "No folders",
                        style = TextStyle(
                            fontSize = 14.sp,
                            color = ColorProvider(Color(0xFF808080))
                        )
                    )
                }
            } else {
                // Build folder -> count map
                val countMap = mutableMapOf<String, Int>()
                for (folder in folders) {
                    countMap[folder] = 0
                }
                for (task in tasks) {
                    if (!task.completed && countMap.containsKey(task.folder)) {
                        countMap[task.folder] = countMap[task.folder]!! + 1
                    }
                }

                LazyColumn {
                    items(folders) { folder ->
                        FolderRow(folder, countMap[folder] ?: 0)
                    }
                }
            }
        }
    }

    @Composable
    private fun FolderRow(folder: String, count: Int) {
        Row(
            modifier = GlanceModifier
                .fillMaxWidth()
                .padding(vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Folder icon
            Image(
                provider = ImageProvider(R.drawable.widget_folder),
                contentDescription = null,
                modifier = GlanceModifier.size(20.dp)
            )

            Spacer(modifier = GlanceModifier.width(12.dp))

            // Folder name
            Text(
                text = folder,
                style = TextStyle(
                    fontSize = 14.sp,
                    color = ColorProvider(Color(0xFF1D1D1D))
                ),
                modifier = GlanceModifier.defaultWeight(),
                maxLines = 1
            )

            // Task count
            Text(
                text = count.toString(),
                style = TextStyle(
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Medium,
                    color = if (count > 0)
                        ColorProvider(Color(0xFF1D1D1D))
                    else
                        ColorProvider(Color(0xFFB0B0B0))
                )
            )
        }
    }
}
