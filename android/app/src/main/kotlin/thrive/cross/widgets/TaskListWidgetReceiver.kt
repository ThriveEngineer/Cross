package thrive.cross.widgets

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class TaskListWidgetReceiver : HomeWidgetGlanceWidgetReceiver<TaskListWidget>() {
    override val glanceAppWidget = TaskListWidget()
}
