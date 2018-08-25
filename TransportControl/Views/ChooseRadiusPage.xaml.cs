using TransportControl.Models;
using TransportControl.ViewModels;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using System.Linq;
using Plugin.Geolocator.Abstractions;
using System;
using Plugin.Connectivity;
using Acr.UserDialogs;
using System.Collections.Generic;
using TransportControl.List;

namespace TransportControl
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class ChooseRadiusPage : ContentPage, IVehicleLoadingPage
    {
        public ChooseRadiusPage()
        {
            InitializeComponent();
            BindingContext = new RadiusViewModel();
        }

        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

        void Handle_ItemTapped(object sender, ItemTappedEventArgs e) => ((ListView)sender).SelectedItem = null;

        async void Handle_ItemSelected(object sender, SelectedItemChangedEventArgs e)
        {
            await Permissions.Check();

            var geoLocator = new GeoLocator();

            var progressDialog = UserDialogs.Instance.Progress(new ProgressDialogConfig());
            progressDialog.Show();

            var userPosition = await geoLocator.GetUserLocationAsync();
            if (userPosition == null)
            {
                progressDialog.Hide();
                return;
            }

            var userCoords = Coordinates.FromPosition(userPosition);

            var distance = e.SelectedItem as Distance;
            var radius = distance.Value;

            if (!CrossConnectivity.Current.IsConnected)
            {
                Dialogs.ShowAlertDialog("Error retrieving data.", "No internet connection.");
                return;
            }

            var loader = new Loader();
            var buses = await loader.LoadAllVehiclesOfType(1);
            var trams = await loader.LoadAllVehiclesOfType(2);
            var vehicles = buses.Concat(trams);

            var nearVehicles = vehicles.Where(v => userCoords.DistanceTo(Coordinates.FromPosition(new Position()
            {
                Latitude = v.LatDbl,
                Longitude = v.LonDbl
            }), UnitOfLength.Meters) <= radius).ToList();

            if (nearVehicles != null)
            {
                var lineNumbers = nearVehicles.Select(v => v.Number);
                List<Line> lines = new List<Line>();
                foreach (var number in lineNumbers)
                {
                    var line = LineHelper.FindBy(symbol: number);
                    if (line != null) lines.Add(line);
                }

                OnVehiclesLoaded?.Invoke(this, new VehiclesLoadedEventArgs(nearVehicles, lines));
                progressDialog.Hide();
                await Navigation.PopAsync();
            }
        }
    }
}