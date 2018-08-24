using TransportControl.ViewModels;
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
            BindingContext = new MapViewModel(Navigation);

            map.InitialCameraUpdate = CameraUpdateFactory.NewPositionZoom(new Position(52.237049, 21.017532), 11d);
            map.CameraChanged += Map_CameraChanged;  
        }

        private void Map_CameraChanged(object sender, CameraChangedEventArgs e)
        {
            map.InitialCameraUpdate = CameraUpdateFactory.NewCameraPosition(e.Position);
        }
    }
}
