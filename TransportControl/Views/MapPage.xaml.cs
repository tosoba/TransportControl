using ReactiveUI;
using System;
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

            var mapStyle = ThemeManager.CurrentTheme == ThemeManager.ThemeType.Light ? MapExtensions.Style.LIGHT : MapExtensions.Style.DARK;
            ThemeManager.OnThemeChanged += OnThemeChanged;
            map.InitializeWithDefaults(mapStyle);
            map.CameraIdled += OnMapCameraIdled;
            map.PinClicked += OnPinClicked;

            this.WhenActivated(disposables =>
            {
                Title = "Transport Control";

                this.BindCommand(ViewModel, vm => vm.GoToLines, view => view.ShowLinesBtn);
                this.BindCommand(ViewModel, vm => vm.GoToLocation, view => view.ShowLocationBtn);
                this.BindCommand(ViewModel, vm => vm.ClearMap, view => view.ClearMapBtn);
                this.BindCommand(ViewModel, vm => vm.ToggleTheme, view => view.ThemesMenuItem);

                if (ViewModel != null && !handlersAttached)
                {
                    ViewModel.OnBoundsCalculated += OnBoundsCalculated;
                    ViewModel.OnVehicleTrackingStarted += OnVehicleTrackingStarted;
                    ViewModel.OnVehiclesTrackingStopped += OnVehiclesTrackingStopped;
                    handlersAttached = true;
                }

                ThemesMenuItem.Text = ThemeManager.CurrentTheme == ThemeManager.ThemeType.Light ? "Dark" : "Light";
            });
        }

        protected override bool OnBackButtonPressed()
        {
            if (ViewModel.IsRunning)
            {
                ViewModel.ClearMap.Execute(new object());
                return true;
            }
            else
            {
                return base.OnBackButtonPressed();
            }
        }

        private void OnThemeChanged(object sender, ThemeChangedEventArgs e)
        {
            switch (e.ThemeType)
            {
                case ThemeManager.ThemeType.Light:
                    map.LoadAndSetStyle(MapExtensions.Style.LIGHT);
                    ThemesMenuItem.Text = "Dark";
                    break;
                case ThemeManager.ThemeType.Dark:
                    map.LoadAndSetStyle(MapExtensions.Style.DARK);
                    ThemesMenuItem.Text = "Light";
                    break;
            }
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
                Tag = Guid.NewGuid(),
                Type = PinType.Place,
                Label = vehicle.Label,
                Position = new Position(vehicle.LatDbl, vehicle.LonDbl),
                Icon = BitmapDescriptorFactory.FromView(new PinView(vehicle.Number, "pin.png"))
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

        private void OnPinClicked(object sender, PinClickedEventArgs e)
        {
            var vehicle = ViewModel.FindByPinTag((Guid)e.Pin.Tag);
            if (vehicle != null) e.Pin.Label = vehicle.Label;
            e.Handled = false;
        }
    }
}
