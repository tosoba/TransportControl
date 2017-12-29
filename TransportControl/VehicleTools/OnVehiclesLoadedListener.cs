using System;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl
{
    public static class OnVehiclesLoadedListener
    {
        public static async void OnVehiclesLoaded(object sender, VehiclesLoadedEventArgs e)
        {
            var updater = VehicleUpdater.Instance;
            if (e.Vehicles.Count > 0)
            {
                updater.AddLines(e.Lines);
                updater.AddVehicles(e.Vehicles);
                updater.StartUpdates();

                var bounds = VehicleHelper.GetBounds(e.Vehicles);
                await updater.Map.AnimateCamera(CameraUpdateFactory.NewBounds(bounds, 50), TimeSpan.FromSeconds(1.5));
            }
        }
    }
}
