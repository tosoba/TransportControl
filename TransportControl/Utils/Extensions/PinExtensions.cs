using System;
using TransportControl.Utils;
using Xamarin.Forms;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl
{
    public static class PinExtensions
    {
        public static void MoveTo(this Pin self, Position finalPos) => Device.BeginInvokeOnMainThread(() =>
        {
            self.Position = finalPos;
        });

        public static void AnimateTo(this Pin self, Position finalPos, double durationMillis = 500)
        {
            var startPosition = new Position(self.Position.Latitude, self.Position.Longitude);
            var startTime = DateTimeOffset.Now.ToUnixTimeMilliseconds();

            Device.StartTimer(TimeSpan.FromMilliseconds(16), () =>
            {
                var elapsed = DateTimeOffset.Now.ToUnixTimeMilliseconds() - startTime;
                var multiplier = Interpolator.GetInterpolation(elapsed / (float)durationMillis);
                double lng = multiplier * finalPos.Longitude + (1 - multiplier)
                        * startPosition.Longitude;
                double lat = multiplier * finalPos.Latitude + (1 - multiplier)
                        * startPosition.Latitude;

                self.Position = new Position(lat, lng);
                return elapsed < durationMillis;
            });
        }

        public static void UpdateLabel(this Pin self, string label) => Device.BeginInvokeOnMainThread(() =>
        {
            self.Label = label;
        });
    }
}
