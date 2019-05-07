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

        public static void AnimateTo(this Pin self, Position endPosition)
        {
            var startPosition = new Position(self.Position.Latitude, self.Position.Longitude);
            var startTime = DateTimeOffset.Now.ToUnixTimeMilliseconds();
            var durationMillis = GetAnimationDuration(startPosition, endPosition);

            Device.StartTimer(TimeSpan.FromMilliseconds(16), () =>
            {
                var elapsed = DateTimeOffset.Now.ToUnixTimeMilliseconds() - startTime;
                var multiplier = Interpolator.GetInterpolation(elapsed / durationMillis);
                var lng = multiplier * endPosition.Longitude + (1 - multiplier) * startPosition.Longitude;
                var lat = multiplier * endPosition.Latitude + (1 - multiplier) * startPosition.Latitude;
                self.Position = new Position(lat, lng);
                return elapsed < durationMillis;
            });
        }

        private static float GetAnimationDuration(Position startPosition, Position endPosition)
        {
            var distance = Coordinates.FromMapPosition(startPosition).DistanceTo(Coordinates.FromMapPosition(endPosition), UnitOfLength.Meters);
            if (distance < 200) return 500;
            else if (distance < 500) return 1000;
            else return 1500;
        }

        public static void UpdateLabel(this Pin self, string label) => Device.BeginInvokeOnMainThread(() =>
        {
            self.Label = label;
        });
    }
}
