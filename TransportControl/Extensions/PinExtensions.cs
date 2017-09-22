using Xamarin.Forms;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl.MapPin
{
    public static class PinExtensions
    {
        public static void MoveTo(this Pin self, Position finalPos)
        {
            Device.BeginInvokeOnMainThread(() =>
            {
                self.Position = finalPos;
            });
        }

        public static void UpdateLabel(this Pin self, string label)
        {
            Device.BeginInvokeOnMainThread(() =>
            {
                self.Label = label;
            });
        }
    }
}
