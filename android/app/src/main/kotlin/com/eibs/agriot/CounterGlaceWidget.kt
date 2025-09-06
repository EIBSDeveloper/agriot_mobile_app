package com.eibs.agriot

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import  com.eibs.agriot.ClearAction
import  com.eibs.agriot.IncrementAction
import  com.eibs.agriot.MainActivity
import es.antonborri.home_widget.actionStartActivity

class CounterGlanceWidget : GlanceAppWidget() {

    // Needed for Updating
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceContent(context, currentState())
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val data = currentState.preferences
        val count = data.getInt("counter", 0)

        Box(
            modifier = GlanceModifier.background(Color.White).padding(16.dp)
                .clickable(onClick = actionStartActivity<MainActivity>(context))
        ) {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Vertical.CenterVertically,
                horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
            ) {
                Text(
                    "You have pushed the button this many times:",
                    style = TextStyle(fontSize = 14.sp, textAlign = TextAlign.Center),
                )
                Text(
                    count.toString(),
                    style = TextStyle(
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        textAlign = TextAlign.Center
                    ),
                )

                Spacer(GlanceModifier.defaultWeight())

                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally

                ) {
                    Box(
                        modifier = GlanceModifier.clickable(onClick = actionRunCallback<ClearAction>(
//                            parameters: ActionPar
                        ))
                            .width(60.dp).height(60.dp),
                        contentAlignment = Alignment.Center
                    )
                    {
                        Text(
                            text = "-",
                            style = TextStyle(fontSize = 50.sp, textAlign = TextAlign.Center),
                        )
                    }
                    Spacer(GlanceModifier.width(50.dp))
                    Box(
                        modifier = GlanceModifier.clickable(onClick = actionRunCallback<IncrementAction>())
                            .width(60.dp).height(60.dp),
                        contentAlignment = Alignment.Center
                    )
                    {
                        Text(
                            text = "+",
                            style = TextStyle(fontSize = 50.sp, textAlign = TextAlign.Center),
                        )

                    }
                }

            }
        }
    }
}