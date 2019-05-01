using ReactiveUI;
using System;
using System.Linq;
using TransportControl.Events;
using TransportControl.Utils;
using TransportControl.Utils.Extensions;
using TransportControl.ViewModels;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl.Views
{
    public partial class MapPage : BaseContentPage<MapViewModel>
    { 
        private bool handlersAttached = false;

        public MapPage()
        {
            InitializeComponent();

            var mapStyle = ThemeManager.CurrentTheme() == ThemeManager.ThemeType.Light ? MapExtensions.Style.LIGHT : MapExtensions.Style.DARK;
            map.InitializeWithDefaults(mapStyle);
            map.CameraIdled += OnMapCameraIdled;

            this.WhenActivated(disposables =>
            {
                Title = "Transport Control";

                this.BindCommand(ViewModel, vm => vm.GoToLines, view => view.ShowLinesBtn);
                this.BindCommand(ViewModel, vm => vm.GoToLocation, view => view.ShowLocationBtn);
                this.BindCommand(ViewModel, vm => vm.ClearMap, view => view.ClearMapBtn);
                this.BindCommand(ViewModel, vm => vm.GoToThemes, view => view.ThemesMenuItem);

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
                    BitmapDescriptorFactory.FromView(new PinView(vehicle.Number, "pin_a.png"))
                    : BitmapDescriptorFactory.FromView(new PinView(vehicle.Number, "pin_t.png"))
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
