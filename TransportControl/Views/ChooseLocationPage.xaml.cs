using ReactiveUI;
using System;
using TransportControl.Utils;
using TransportControl.Utils.Extensions;
using TransportControl.ViewModels;
using Xamarin.Forms.GoogleMaps;
using Xamarin.Forms.Xaml;

namespace TransportControl.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class ChooseLocationPage : BaseContentPage<ChooseLocationViewModel>
    {
        public Pin ChosenLocationPin { get; set; }

        public ChooseLocationPage()
        {
            InitializeComponent();

            var mapStyle = ThemeManager.CurrentTheme == ThemeManager.ThemeType.Light ? MapExtensions.Style.LIGHT : MapExtensions.Style.DARK;
            map.InitializeWithDefaults(mapStyle);
            map.CameraIdled += OnMapCameraIdled;
            map.MapLongClicked += OnMapLongClicked;

            ClearBtn.Clicked += OnClearBtnClicked;

            this.WhenActivated(disposables =>
            {
                this.BindCommand(ViewModel, vm => vm.AddToFavourites, view => view.AddToFavouritesBtn);
                this.BindCommand(ViewModel, vm => vm.GoToRadius, view => view.ConfirmBtn);

                if (ChosenLocationPin != null)
                {
                    ViewModel.ChosenLocation = new Models.Location()
                    {
                        Name = "Chosen location",
                        Lat = ChosenLocationPin.Position.Latitude,
                        Lon = ChosenLocationPin.Position.Longitude
                    };
                }
            });
        }

        private void OnClearBtnClicked(object sender, EventArgs e)
        {
            HintLabel.IsVisible = true;
            ChooseLocationButtonsGrid.IsVisible = false;
            ViewModel.ChosenLocation = null;
            map.Pins.Clear();
            ChosenLocationPin = null;
        }

        private void OnMapLongClicked(object sender, MapLongClickedEventArgs e)
        {
            map.Pins.Clear();
            ChosenLocationPin = new Pin()
            {
                Type = PinType.Place,
                Position = new Position(e.Point.Latitude, e.Point.Longitude),
                Label = "Chosen location"
            };
            ViewModel.ChosenLocation = new Models.Location()
            {
                Name = "Chosen location",
                Lat = e.Point.Latitude,
                Lon = e.Point.Longitude
            };
            map.Pins.Add(ChosenLocationPin);
            HintLabel.IsVisible = false;
            ChooseLocationButtonsGrid.IsVisible = true;
        }

        private void OnMapCameraIdled(object sender, CameraIdledEventArgs e)
        {
            map.InitialCameraUpdate = CameraUpdateFactory.NewCameraPosition(e.Position);
        }
    }
}