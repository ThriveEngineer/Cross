package thrive.cross.widgets

import thrive.cross.R
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextDecoration
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class DueTodayWidget : GlanceAppWidget() {

    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent { Content(context, currentState()) }
    }

    @Composable
    private fun Content(context: Context, state: HomeWidgetGlanceState) {
        val prefs = state.preferences
        val isPro = prefs.getString("widget_is_pro", "") == "true"
        val tasks = parseTasks(prefs.getString("widget_tasks", null))

        val today = LocalDate.now().toString() // yyyy-MM-dd
        val dueTodayTasks = tasks.filter { task ->
            task.date != null && task.date.startsWith(today)
        }

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(Color.White)
                .padding(top = 16.dp, start = 16.dp, end = 16.dp, bottom = 8.dp)
        ) {
            // Header
            Text(
                text = "Due Today",
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

            Spacer(modifier = GlanceModifier.height(8.dp))

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
            } else if (dueTodayTasks.isEmpty()) {
                Box(
                    modifier = GlanceModifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "All clear!",
                            style = TextStyle(
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Medium,
                                color = ColorProvider(Color(0xFF1D1D1D))
                            )
                        )
                        Spacer(modifier = GlanceModifier.height(4.dp))
                        Text(
                            text = "Nothing due today",
                            style = TextStyle(
                                fontSize = 13.sp,
                                color = ColorProvider(Color(0xFF808080))
                            )
                        )
                    }
                }
            } else {
                LazyColumn {
                    items(dueTodayTasks.take(8)) { task ->
                        TaskRow(task)
                    }
                }
            }
        }
    }

    @Composable
    private fun TaskRow(task: WidgetTask) {
        Row(
            modifier = GlanceModifier
                .fillMaxWidth()
                .padding(vertical = 7.dp)
                .clickable(
                    actionRunCallback<TickTaskAction>(
                        actionParametersOf(
                            TickTaskAction.uriKey to "cross://tick?index=${task.index}"
                        )
                    )
                ),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Checkbox
            Image(
                provider = ImageProvider(
                    if (task.completed) R.drawable.widget_checkbox_checked
                    else R.drawable.widget_checkbox_unchecked
                ),
                contentDescription = null,
                modifier = GlanceModifier.size(20.dp)
            )

            Spacer(modifier = GlanceModifier.width(12.dp))

            // Task name
            Text(
                text = task.name,
                style = TextStyle(
                    fontSize = 15.sp,
                    color = if (task.completed)
                        ColorProvider(Color(0xFF808080))
                    else
                        ColorProvider(Color(0xFF1D1D1D)),
                    textDecoration = if (task.completed)
                        TextDecoration.LineThrough
                    else
                        TextDecoration.None
                ),
                maxLines = 1
            )
        }
    }
}
