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

        async void Handle_ItemSelected(object sender, SelectedItemChangedEventArgs e)
        {
            if (e.SelectedItem == null) return;

            await Permissions.Check();

            var distance = new Distance(e.SelectedItem as Distance);
            var radius = distance.Value;

            var geoLocator = new GeoLocator();

            var progressDialog = UserDialogs.Instance.Progress(new ProgressDialogConfig());
            progressDialog.Show();

            var userPosition = await geoLocator.GetUserLocationAsync();
            if (userPosition == null)
            {
                RadiusListView.SelectedItem = null;

                progressDialog.Hide();
                return;
            }

            if (!CrossConnectivity.Current.IsConnected)
            {
                Dialogs.ShowAlertDialog("Error retrieving data.", "No internet connection.");
                return;
            }

            var userCoords = Coordinates.FromPosition(userPosition);
            var loader = new Loader();
            var buses = await loader.LoadAllVehiclesOfType(1);
            var trams = await loader.LoadAllVehiclesOfType(2);
            var vehicles = buses.Concat(trams);

            var nearVehicles = vehicles.Where(v => userCoords.DistanceTo(Coordinates.FromPosition(new Position()
            {
                Latitude = v.LatDbl,
                Longitude = v.LonDbl
            }), UnitOfLength.Meters) <= distance.Value).ToList();

            if (nearVehicles != null && nearVehicles.Count > 0)
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

                RadiusListView.SelectedItem = null;

                await Navigation.PopAsync();
            }
            else
            {
                progressDialog.Hide();
                RadiusListView.SelectedItem = null;
                Dialogs.ShowAlertDialog("Error retrieving data.", "No vehicles found.");
            }
        }
    }
}