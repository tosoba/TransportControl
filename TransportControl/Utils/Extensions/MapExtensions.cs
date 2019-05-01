using System.IO;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl.Utils.Extensions
{
    public static class MapExtensions
    {
        public enum Style{
            LIGHT, DARK
        }
        public static void InitializeWithDefaults(this Map map, Style style)
        {
            string stylePath = style == Style.DARK ? "TransportControl.Resources.dark_map.json" : "TransportControl.Resources.light_map.json";
            map.MapStyle = MapStyle.FromJson(new StreamReader(stylePath.ResourceStream()).ReadToEnd());
            map.InitialCameraUpdate = CameraUpdateFactory.NewPositionZoom(App.warsawCenterPosition, 11d);
            map.UiSettings.ZoomControlsEnabled = false;
        }
    }
}
