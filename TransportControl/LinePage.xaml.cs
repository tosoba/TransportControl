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
    public partial class LinePage : ContentPage, ILoadingPage
    {
        public LinePage()
        {
            InitializeComponent();
            BindingContext = new LinesViewModel();
        }

        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

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

            var dialog = UserDialogs.Instance.Progress(new ProgressDialogConfig());
            dialog.Show();

            var loader = new Loader();
            var vehicles = await loader.LoadVehicles(line.Symbol, 1);
            if (vehicles != null)
            {
                OnVehiclesLoaded?.Invoke(this, new VehiclesLoadedEventArgs(vehicles, new List<Line>() { line }));
                dialog.Hide();
                await Navigation.PopAsync();
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
            var target = LineHelper.LinesGrouped.FirstOrDefault(group => group.Any(line => line.Symbol.StartsWith(startsWith)))?.FirstOrDefault();
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
