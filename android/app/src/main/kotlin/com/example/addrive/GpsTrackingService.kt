package com.techfifo.addrive

import android.app.*
import android.content.Intent
import android.content.pm.ServiceInfo
import android.location.Location
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.*
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject

class GpsTrackingService : Service() {

    companion object {
        private const val TAG = "GPS_SERVICE"
    }

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🚀 Service CREATED")

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        startForegroundServiceInternal()
        startLocationUpdates()
    }

    private fun startLocationUpdates() {

        Log.d(TAG, "📡 Starting location updates")

        val locationRequest = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            10_000L
        )
            .setMinUpdateIntervalMillis(10_000L)
            .setMinUpdateDistanceMeters(0f)
            .build()

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                val location = result.lastLocation
                if (location == null) {
                    Log.d(TAG, "⚠️ Location is NULL")
                    return
                }

                Log.d(
                    TAG,
                    "📍 Location callback fired: ${location.latitude}, ${location.longitude}"
                )

                sendGps(location)
            }
        }

        fusedLocationClient.requestLocationUpdates(
            locationRequest,
            locationCallback,
            Looper.getMainLooper()
        )
    }

    private fun sendGps(location: Location) {
        Log.d(TAG, "➡️ sendGps() called")

        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val tripId = prefs.getLong("flutter.current_trip_id", -1L)
        val token = prefs.getString("flutter.access_token", null)

        Log.d(TAG, "🧾 tripId=$tripId token=${token != null}")

        if (tripId == -1L || token.isNullOrEmpty()) {
            Log.d(TAG, "⛔ Skipping API call (invalid trip or token)")
            return
        }

        val json = JSONObject().apply {
            put("trip_id", tripId)
            put("latitude", location.latitude)
            put("longitude", location.longitude)
            put("access_token", token)
        }

        Log.d(TAG, "🌐 Sending API request")

        val request = Request.Builder()
            .url("http://192.168.1.48:3000/gps/update")
            .post(json.toString().toRequestBody("application/json".toMediaType()))
            .build()

        OkHttpClient().newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: java.io.IOException) {
                Log.e(TAG, "❌ API FAILED: ${e.message}")
            }

            override fun onResponse(call: Call, response: Response) {
                Log.d(TAG, "✅ API SUCCESS code=${response.code}")
                response.close()
            }
        })
    }

    private fun startForegroundServiceInternal() {

        val channelId = "gps_tracking"

        val channel = NotificationChannel(
            channelId,
            "GPS Tracking",
            NotificationManager.IMPORTANCE_LOW
        )

        getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("AdDrive Ride Active")
            .setContentText("Tracking GPS every 10 seconds")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                101,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
            )
        } else {
            startForeground(101, notification)
        }

        Log.d(TAG, "🔔 Foreground notification shown")
    }

    override fun onDestroy() {
        Log.d(TAG, "🛑 Service DESTROYED")
        fusedLocationClient.removeLocationUpdates(locationCallback)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
