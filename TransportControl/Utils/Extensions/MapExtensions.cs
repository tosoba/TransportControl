using System.IO;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl.Utils.Extensions
{
    public static class MapExtensions
    {
        public static void InitializeWithDefaults(this Map map)
        {
            map.MapStyle = MapStyle.FromJson(new StreamReader("TransportControl.Resources.map.json".ResourceStream()).ReadToEnd());
            map.InitialCameraUpdate = CameraUpdateFactory.NewPositionZoom(App.warsawCenterPosition, 11d);
            map.UiSettings.ZoomControlsEnabled = false;
        }
    }
}
