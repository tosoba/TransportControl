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
    public partial class ChooseRadiusPage : ContentPage, ILoadingPage
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
            var userPosition = await geoLocator.GetUserLocationAsync();
            if (userPosition == null)
            {
                Dialogs.ShowAlertDialog("Error retrieving location", "Failed to retrieve location after 15 secs.");
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

            var progressDialog = UserDialogs.Instance.Progress(new ProgressDialogConfig());
            progressDialog.Show();

            var loader = new Loader();
            var vehicles = await loader.LoadAllVehiclesOfType(1);

            //dummy location
            userCoords = new Coordinates(52.23, 21);

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