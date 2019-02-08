using ReactiveUI;
using System;
using System.Linq;
using TransportControl.Events;
using TransportControl.ViewModels;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl.Views
{
    public partial class MapPage : BaseContentPage<MapViewModel>
    {
        private readonly Position warsawCenterPosition = new Position(52.237049, 21.017532);
        private const double initialZoom = 11d;

        private bool handlersAttached = false;

        public MapPage()
        {
            InitializeComponent();

            map.InitialCameraUpdate = CameraUpdateFactory.NewPositionZoom(warsawCenterPosition, initialZoom);
            map.CameraIdled += OnMapCameraIdled;

            this.WhenActivated(disposables =>
            {
                Title = "Transport Control";

                disposables(this.BindCommand(ViewModel, vm => vm.GoToLines, view => view.ShowLinesBtn));
                disposables(this.BindCommand(ViewModel, vm => vm.GoToRadius, view => view.ShowRadiusBtn));
                disposables(this.BindCommand(ViewModel, vm => vm.ClearMap, view => view.ClearMapBtn));

                if (ViewModel != null && !handlersAttached)
                {
                    ViewModel.OnBoundsCalculated += OnBoundsCalculated;
                    ViewModel.OnVehicleTrackingStarted += OnVehicleTrackingStarted;
                    ViewModel.OnVehiclesTrackingStopped += OnVehiclesTrackingStopped;
                    handlersAttached = true;
                }
            });
        }

        private void OnVehiclesTrackingStopped(object sender, VehiclesTrackingStoppedEventArgs e)
        {
            map.Pins.Clear();
        }

        private void OnVehicleTrackingStarted(object sender, VehicleTrackingStartedEventArgs e)
        {
            var vehicle = e.Vehicle;
            vehicle.Pin = new Pin
            {
                Type = PinType.Place,
                Label = $"Last update at: {vehicle.Time}",
                Position = new Position(vehicle.LatDbl, vehicle.LonDbl),
                Icon = char.IsLetter(vehicle.Number.First()) || vehicle.NumberInt >= 100 ?
                    BitmapDescriptorFactory.FromView(new PinView(vehicle.Number, "pin_red_a.png"))
                    : BitmapDescriptorFactory.FromView(new PinView(vehicle.Number, "pin_red_t.png"))
            };
            map.Pins.Add(vehicle.Pin);
        }

        private async void OnBoundsCalculated(object sender, BoundsCalculatedEventArgs e)
        {
            await map.AnimateCamera(
                cameraUpdate: CameraUpdateFactory.NewBounds(e.Bounds, 50),
                duration: TimeSpan.FromSeconds(1.5)
            );
        }

        private void OnMapCameraIdled(object sender, CameraIdledEventArgs e)
        {
            map.InitialCameraUpdate = CameraUpdateFactory.NewCameraPosition(e.Position);
        }
    }
}
