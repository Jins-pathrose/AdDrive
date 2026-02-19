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
        LogStream.send("🚀 GPS Service created")

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        startForegroundServiceInternal()
        startLocationUpdates()
    }

    private fun startLocationUpdates() {

        Log.d(TAG, "📡 Starting location updates")
        LogStream.send("📡 Starting location updates")

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
                    LogStream.send("⚠️ Location is NULL")
                    return
                }

                Log.d(
                    TAG,
                    "📍 Location: ${location.latitude}, ${location.longitude}"
                )

                LogStream.send(
                    "📍 Location received → Lat: ${location.latitude}, Lng: ${location.longitude}"
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

        val lat = location.latitude
        val lng = location.longitude

        LogStream.send("➡️ sendGps() called")

        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val tripId = prefs.getLong("flutter.current_trip_id", -1L)
        val token = prefs.getString("flutter.access_token", null)

        LogStream.send("🧾 tripId=$tripId token=${token != null}")

        if (tripId == -1L || token.isNullOrEmpty()) {
            LogStream.send("⛔ Skipping API call (invalid trip or token)")
            return
        }

        val json = JSONObject().apply {
            put("trip_id", tripId)
            put("latitude", lat)
            put("longitude", lng)
        }

        LogStream.send("🌐 Sending API payload: $json")

        val request = Request.Builder()
            .url("https://backend.drarifdentistry.com/api/update-location")
            .addHeader("Authorization", "Bearer $token")
            .addHeader("Content-Type", "application/json")
            .post(json.toString().toRequestBody("application/json".toMediaType()))
            .build()

        OkHttpClient().newCall(request).enqueue(object : Callback {

            override fun onFailure(call: Call, e: java.io.IOException) {
                Log.e(TAG, "❌ API FAILED: ${e.message}")
                LogStream.send("❌ API FAILED: ${e.message}")
            }

            override fun onResponse(call: Call, response: Response) {
                LogStream.send("✅ API SUCCESS (${response.code})")
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

        LogStream.send("🔔 Foreground service started")
    }

    override fun onDestroy() {
        LogStream.send("🛑 GPS Service destroyed")
        fusedLocationClient.removeLocationUpdates(locationCallback)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
