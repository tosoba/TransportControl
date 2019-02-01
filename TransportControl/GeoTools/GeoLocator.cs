using Plugin.Geolocator;
using Plugin.Geolocator.Abstractions;
using System;
using System.Threading.Tasks;

namespace TransportControl
{
    public static class GeoLocator
    {
        public static async Task<Position> GetUserLocationAsync()
        {
            try
            {
                if (!CrossGeolocator.IsSupported || !CrossGeolocator.Current.IsGeolocationAvailable)
                {
                    Dialogs.ShowAlertDialog("Error retrieving location.", "Device does not support geolocation.");
                    return null;
                }
                if (!CrossGeolocator.Current.IsGeolocationEnabled)
                {
                    Dialogs.ShowAlertDialog("Error retrieving location.", "Enable location.");
                    return null;
                }

                var lastKnownLocation = await CrossGeolocator.Current.GetLastKnownLocationAsync();
                if (lastKnownLocation != null) return lastKnownLocation;

                var currentLocation = await CrossGeolocator.Current.GetPositionAsync(TimeSpan.FromSeconds(15), null, true);
                return currentLocation;
            }
            catch (Exception e)
            {
                Dialogs.ShowAlertDialog("Error retrieving location.", $"Exception thrown: {e.Message}");
                return null;
            }
        }
    }
}
