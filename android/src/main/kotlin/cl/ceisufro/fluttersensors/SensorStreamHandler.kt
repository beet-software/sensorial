package cl.ceisufro.fluttersensors

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel
import java.util.concurrent.TimeUnit
import java.util.*


class SensorStreamHandler(private val sensorManager: SensorManager, sensorId: Int, private var interval: Int?) : EventChannel.StreamHandler, SensorEventListener {
    private val sensor: Sensor? = sensorManager.getDefaultSensor(sensorId)
    private var eventSink: EventChannel.EventSink? = null
    private var lastUpdate: Calendar = Calendar.getInstance()
    private var customDelay: Boolean = false

    init {
        interval = interval ?: SensorManager.SENSOR_DELAY_NORMAL
        configSensor(interval!!)
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        if (sensor != null) {
            this.eventSink = eventSink
            startListener()
        }
    }

    override fun onCancel(arguments: Any?) {
        stopListener()
    }

    private fun configSensor(interval: Int) {
        this.interval = interval
        this.customDelay = interval > SensorManager.SENSOR_DELAY_NORMAL
    }

    private fun startListener() {
        sensorManager.registerListener(this, sensor, interval!!)
    }

    fun stopListener() {
        sensorManager.unregisterListener(this)
    }

    fun updateInterval(interval: Int?) {
        if (interval != null) {
            configSensor(interval)
            stopListener()
            startListener()
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        /// Not implemented
    }

    override fun onSensorChanged(event: SensorEvent?) {
        val currentTime = Calendar.getInstance()
        if (event != null && isValidTime(currentTime)) {
            val data = arrayListOf<Float>()
            event.values.forEach(data::add)
            notifyEvent(event.sensor.type, data, event.accuracy, TimeUnit.NANOSECONDS.toMillis(event.timestamp))
            lastUpdate = currentTime
        }
    }

    private fun isValidTime(time: Calendar): Boolean {
        if (customDelay) {
            val diff = (time.timeInMillis - lastUpdate.timeInMillis) * 1000
            return diff > interval!!
        }
        return true
    }

    private fun notifyEvent(sensorId: Int, data: ArrayList<Float>, accuracy: Int, timestamp: Long) {
        val resultMap = mutableMapOf<String, Any?>(
                "sensorId" to sensorId,
                "timestamp" to timestamp,
                "data" to data,
                "accuracy" to accuracy)
        eventSink?.success(resultMap)
    }
}