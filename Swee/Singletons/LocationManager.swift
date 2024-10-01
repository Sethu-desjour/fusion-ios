import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var lastKnownCity: String?
    var manager = CLLocationManager()
    
    
    func checkLocationAuthorization() {
        
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined://The user choose allow or denny your app to get the location yet
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
            print("Location not determined")
        case .restricted://The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
            print("Location restricted")
            
        case .denied://The user dennied your app to get location or disabled the services location or the phone is in airplane mode
            print("Location denied")
            
        case .authorizedWhenInUse, .authorizedAlways://This authorization allows you to use all location services and receive location events only when your app is in use
            lastKnownLocation = manager.location?.coordinate
            getLastKnownCity()
            
        @unknown default:
            print("Location service disabled")
            
        }
    }
    
    func getLastKnownCity() {
        guard let lastKnownLocation = lastKnownLocation else {
            return
        }
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lastKnownLocation.latitude, longitude: lastKnownLocation.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler:
                                            {
            placemarks, error -> Void in
            
            guard let placeMark = placemarks?.first else { return }
            if let city = placeMark.subAdministrativeArea {
                self.lastKnownCity = city
            } else if let country = placeMark.country {
                self.lastKnownCity = country
            }
        })
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
}
