using TransportControl.Utils.Extensions;
using TransportControl.ViewModels;
using Xamarin.Forms.GoogleMaps;
using Xamarin.Forms.Xaml;

namespace TransportControl.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class ChooseLocationPage : BaseContentPage<ChooseLocationViewModel>
    {
        public ChooseLocationPage()
        {
            InitializeComponent();

            map.InitializeWithDefaults();
            map.CameraIdled += OnMapCameraIdled;
        }

        private void OnMapCameraIdled(object sender, CameraIdledEventArgs e)
        {
            map.InitialCameraUpdate = CameraUpdateFactory.NewCameraPosition(e.Position);
        }
    }
}