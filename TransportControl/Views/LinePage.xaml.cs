using Acr.UserDialogs;
using Plugin.Connectivity;
using System;
using System.Collections.Generic;
using System.Linq;
using TransportControl.List;
using TransportControl.Models;
using TransportControl.ViewModels;
using Xamarin.Forms;

namespace TransportControl
{
    public partial class LinePage : ContentPage, IVehicleLoadingPage
    {
        public LinePage()
        {
            InitializeComponent();
            BindingContext = new LinesViewModel();
        }

        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

        void Handle_ItemTapped(object sender, ItemTappedEventArgs e) => ((ListView)sender).SelectedItem = null;

        async void Handle_ItemSelected(object sender, SelectedItemChangedEventArgs e)
        {
            var line = ((ListView)sender).SelectedItem as Line;
            if (line == null)
                return;

            if (!CrossConnectivity.Current.IsConnected)
            {
                Dialogs.ShowAlertDialog("Error retrieving data.", "No internet connection.");
                return;
            }

            //var progressDialog = UserDialogs.Instance.Progress();
            //progressDialog.Show();

            var loader = new Loader();
            List<Vehicle> vehicles;
            if (char.IsLetter(line.Symbol.First()) || int.Parse(line.Symbol) >= 100)
            {
                vehicles = await loader.LoadVehicles(line.Symbol, 1);
            }
            else
            {
                vehicles = await loader.LoadVehicles(line.Symbol, 2);
            }

            if (vehicles != null && vehicles.Count > 0)
            {
                OnVehiclesLoaded?.Invoke(this, new VehiclesLoadedEventArgs(vehicles, new List<Line>() { line }));
                //progressDialog.Hide();
                await Navigation.PopAsync();
            }
            else
            {
               // progressDialog.Hide();
                Dialogs.ShowAlertDialog("Error retrieving data.", "No vehicles found.");
            }
        }

        void Handle_TextChanged(object sender, TextChangedEventArgs e)
        {
            var keyword = LineSearchBar.Text;
            LineHelper.Filter(keyword);
            LinesListView.ItemsSource = LineHelper.LinesGrouped;
        }

        private void ScrollToItemThat(string startsWith)
        {
            var target = LineHelper.LinesGrouped
                .FirstOrDefault(group => group.Any(line => line.Symbol.StartsWith(startsWith) && line.Symbol.Length > 2))
                ?.FirstOrDefault();
            if (target != null)
            {
                LinesListView.ScrollTo(target, ScrollToPosition.Start, false);
            }
        }

        private void buttonLineNumbers_Clicked(object sender, EventArgs e)
        {
            var label = (sender as Button).Text;
            switch (label)
            {
                case "1":
                    LinesListView.ScrollTo(LineHelper.LinesGrouped
                        .FirstOrDefault(group => group.Any(line => line.Symbol.Length < 3))
                        ?.FirstOrDefault(), ScrollToPosition.Start, false);
                    break;
                case "100":
                    ScrollToItemThat(startsWith: "1"); break;
                case "200":
                    ScrollToItemThat(startsWith: "2"); break;
                case "300":
                    ScrollToItemThat(startsWith: "3"); break;
                case "400":
                    ScrollToItemThat(startsWith: "4"); break;
                case "500":
                    ScrollToItemThat(startsWith: "5"); break;
                case "600":
                    ScrollToItemThat(startsWith: "6"); break;
                case "700":
                    ScrollToItemThat(startsWith: "7"); break;
                case "E":
                    ScrollToItemThat(startsWith: "E"); break;
                default: break;
            }
        }
    }
}
