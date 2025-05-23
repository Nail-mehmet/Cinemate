package com.example.nail

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

class CinemateWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)

            val title = widgetData.getString("widget_title", "Başlık Yok")
            val description = widgetData.getString("widget_description", "Açıklama Yok")
            val imagePath = widgetData.getString("widget_image_path", null)

            val views = RemoteViews(context.packageName, R.layout.cinemate_widget).apply {
                setTextViewText(R.id.text_title, title)
                setTextViewText(R.id.text_description, description)

                if (imagePath != null) {
                    val imageFile = File(imagePath)
                    if (imageFile.exists()) {
                        val bitmap = BitmapFactory.decodeFile(imagePath)
                        setImageViewBitmap(R.id.image_id, bitmap)
                    } else {
                        setImageViewResource(R.id.image_id, R.drawable.default_image)
                    }
                } else {
                    setImageViewResource(R.id.image_id, R.drawable.default_image)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onEnabled(context: Context) {
        // İlk widget eklendiğinde çalışır
    }

    override fun onDisabled(context: Context) {
        // Son widget kaldırıldığında çalışır
    }
}
