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

            map.CameraChanged += Map_CameraChanged;  
        }

        private void Map_CameraChanged(object sender, CameraChangedEventArgs e)
        {
            map.InitialCameraUpdate = CameraUpdateFactory.NewCameraPosition(e.Position);
        }
    }
}
