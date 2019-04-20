using ReactiveUI;
using System;
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

            map.InitializeWithDefaults();
            map.CameraIdled += OnMapCameraIdled;
            map.MapLongClicked += OnMapLongClicked;

            ClearBtn.Clicked += OnClearBtnClicked;

            this.WhenActivated(disposables =>
            {
                this.BindCommand(ViewModel, vm => vm.AddToFavourites, view => view.AddToFavouritesBtn);
                this.BindCommand(ViewModel, vm => vm.GoToRadius, view => view.ConfirmBtn);
            });
        }

        private void OnClearBtnClicked(object sender, EventArgs e)
        {
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
            ChooseLocationButtonsGrid.IsVisible = true;
        }

        private void OnMapCameraIdled(object sender, CameraIdledEventArgs e)
        {
            map.InitialCameraUpdate = CameraUpdateFactory.NewCameraPosition(e.Position);
        }
    }
}