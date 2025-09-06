package com.eibs.agriot

import HomeWidgetGlanceWidgetReceiver
import com.eibs.agriot.CounterGlanceWidget


class CounterGlaceWidgetReceiver : HomeWidgetGlanceWidgetReceiver<CounterGlanceWidget>() {
    override val glanceAppWidget = CounterGlanceWidget()
}