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
        }

        private void OnClearBtnClicked(object sender, System.EventArgs e)
        {
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
            map.Pins.Add(ChosenLocationPin);
        }

        private void OnMapCameraIdled(object sender, CameraIdledEventArgs e)
        {
            map.InitialCameraUpdate = CameraUpdateFactory.NewCameraPosition(e.Position);
        }
    }
}