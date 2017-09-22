using System;
using Xamarin.Forms;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl
{
    public partial class MapPage : ContentPage
    {
        public MapPage()
        {
            InitializeComponent();

            VehicleUpdater.Instance.Map = map;

            var linePage = new LinePage();
            linePage.OnVehiclesLoaded += OnVehiclesLoaded;

            var chooseRadiusPage = new ChooseRadiusPage();
            chooseRadiusPage.OnVehiclesLoaded += OnVehiclesLoaded;

            buttonLines.Clicked += (sender, e) => Navigation.PushAsync(linePage);
            buttonClearMap.Clicked += (sender, e) =>
            {
                VehicleUpdater.Instance.IsRunning = false;
            };
            buttonNearMe.Clicked += (sender, e) => Navigation.PushAsync(chooseRadiusPage);

            map.CameraChanged += Map_CameraChanged;  
        }

        private void Map_CameraChanged(object sender, CameraChangedEventArgs e)
        {
            map.InitialCameraUpdate = CameraUpdateFactory.NewCameraPosition(e.Position);
        }

        private async void OnVehiclesLoaded(object sender, VehiclesLoadedEventArgs e)
        {
            var updater = VehicleUpdater.Instance;
            if (e.Vehicles.Count > 0)
            { 
                updater.AddLines(e.Lines);
                updater.AddVehicles(e.Vehicles);
                updater.StartUpdates();

                var bounds = VehicleHelper.GetBounds(e.Vehicles);
                await map.AnimateCamera(CameraUpdateFactory.NewBounds(bounds, 50), TimeSpan.FromSeconds(1.5));
            }
        }
    }
}
