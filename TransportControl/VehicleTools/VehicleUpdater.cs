using Plugin.Connectivity;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;
using TransportControl.MapPin;
using TransportControl.Models;
using Xamarin.Forms;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl
{
    public class VehicleUpdater
    {
        private static VehicleUpdater instance;
        public static VehicleUpdater Instance
        {
            get
            {
                if (instance == null) return instance = new VehicleUpdater();
                return instance;
            }
        }

        private ObservableCollection<Vehicle> trackedVehicles = new ObservableCollection<Vehicle>();
        private List<Line> trackedLines = new List<Line>();

        private bool isRunning = false;
        public bool IsRunning
        {
            get => isRunning;
            set
            {
                isRunning = value;
                if (isRunning == false)
                {
                    trackedVehicles.Clear();
                    trackedLines.Clear();
                    map?.Pins.Clear();
                }
            }
        }

        private Map map;
        public Map Map
        {
            set
            {
                if (map == null) map = value;
            }
            get => map;
        }

        private VehicleUpdater()
        {
        }

        private Vehicle Find(Vehicle vehicle)
        {
            return trackedVehicles.Where(v => v.Number == vehicle.Number && v.Brigade == vehicle.Brigade).FirstOrDefault();
        }

        private void UpdateVehicle(Vehicle trackedVehicle, Vehicle loadedVehicle)
        {
            trackedVehicle.Lat = loadedVehicle.Lat;
            trackedVehicle.Lon = loadedVehicle.Lon;
            trackedVehicle.Time = loadedVehicle.Time;
            trackedVehicle.Pin.MoveTo(
                new Position(Double.Parse(trackedVehicle.Lat), Double.Parse(trackedVehicle.Lon)) 
            );
            trackedVehicle.Pin.UpdateLabel($"Last update at: {trackedVehicle.Time}");
        }

        private async Task Update()
        {
            if (trackedLines == null) return;

            if (!CrossConnectivity.Current.IsConnected)
            {
                Dialogs.ShowAlertDialog("Error retrieving data.", "No internet connection.");
                return;
            }

            for (int i = 0; i < trackedLines.Count; i++)
            {
                var loader = new Loader();
                var loadedVehicles = await loader.LoadVehicles(trackedLines[i].Symbol, 1);
                if (loadedVehicles != null)
                {
                    AddVehicles(loadedVehicles);
                    for (var j = 0; j < loadedVehicles.Count; j++)
                    {
                        var trackedVehicle = Find(loadedVehicles[j]);
                        if (trackedVehicle != null)
                        {
                            UpdateVehicle(trackedVehicle, loadedVehicles[j]);
                        }
                    }
                }
            }
        }

        private void AddToMap(Vehicle vehicle)
        {
            vehicle.Pin = new Pin
            {
                Type = PinType.Place,
                Label = $"Last update at: {vehicle.Time}",
                Position = new Position(Double.Parse(vehicle.Lat), Double.Parse(vehicle.Lon)),
                Icon = BitmapDescriptorFactory.FromView(new BindingPinView(vehicle.Number))
            };

            map?.Pins.Add(vehicle.Pin);
        }

        private bool IsLineAdded(Line line) => trackedLines.Any(l => l.Symbol == line.Symbol);

        public void AddLines(List<Line> lines)
        {
            foreach (var line in lines)
            {
                if (!IsLineAdded(line))
                    trackedLines.Add(line);
            }
        }

        private bool IsVehicleAdded(Vehicle vehicle) => trackedVehicles.Any(v => v.Number == vehicle.Number && v.Brigade == vehicle.Brigade);

        public void AddVehicles(List<Vehicle> vehicles)
        {
            foreach (var vehicle in vehicles)
            {
                if (!IsVehicleAdded(vehicle))
                {
                    trackedVehicles.Add(vehicle);
                    AddToMap(vehicle);
                }
            }
        }

        public void StartUpdates()
        {
            if (!IsRunning)
            {
                var seconds = TimeSpan.FromSeconds(5);
                Device.StartTimer(seconds, () => 
                {
                    IsRunning = true;
                    Task.Run(async () =>
                    {
                        await Update();
                    });
                    return true;
                });
            }
        }
    }
}
