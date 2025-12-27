import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {

    static let shared = LocationService()
    private let locationManager = CLLocationManager()

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // meters
    }

    func startTracking() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude

        print("📍 iOS location: \(lat), \(lng)")

        sendGps(lat: lat, lng: lng)
    }

    private func sendGps(lat: Double, lng: Double) {
        let defaults = UserDefaults.standard

        let tripId = defaults.integer(forKey: "current_trip_id")
        let token = defaults.string(forKey: "access_token") ?? ""

        if tripId == 0 || token.isEmpty {
            print("⛔ Invalid trip or token")
            return
        }

        let url = URL(string: "https://backend.drarifdentistry.com/gps/update")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "trip_id": tripId,
            "latitude": lat,
            "longitude": lng
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request).resume()
    }
}
