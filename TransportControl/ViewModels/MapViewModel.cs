using System;
using System.Windows.Input;
using Xamarin.Forms;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl.ViewModels
{
    public class MapViewModel
    {
        public INavigation Navigation { get; private set; }

        public ICommand ClearMap { get; }
        public ICommand GoToLines { get; }
        public ICommand GoToRadius { get; }

        public MapViewModel(INavigation navigation)
        {
            Navigation = navigation;

            var linePage = new LinePage();
            linePage.OnVehiclesLoaded += OnVehiclesLoaded;

            var chooseRadiusPage = new ChooseRadiusPage();
            chooseRadiusPage.OnVehiclesLoaded += OnVehiclesLoaded;

            ClearMap = new Command(() =>
            {
                VehicleUpdater.Instance.IsRunning = false;
            });

            GoToLines = new Command(async () =>
            {
                await Navigation.PushAsync(linePage);
            });

            GoToRadius = new Command(async () =>
            {
                await Navigation.PushAsync(chooseRadiusPage);
            });
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
                await updater.Map.AnimateCamera(CameraUpdateFactory.NewBounds(bounds, 50), TimeSpan.FromSeconds(1.5));
            }
        }
    }
}
