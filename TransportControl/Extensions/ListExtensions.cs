using System.Collections.Generic;
using System.Linq;
using TransportControl.Models;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl
{
    public static class ListExtensions
    {
        public static void AddAll<T>(this IList<T> self, IEnumerable<T> items)
        {
            foreach (var item in items)
            {
                self.Add(item);
            }
        }

        public static Bounds GetBounds(this IList<Vehicle> self)
        {
            var minLat = self.Select(v => double.Parse(v.Lat)).Min();
            var minLon = self.Select(v => double.Parse(v.Lon)).Min();
            var maxLat = self.Select(v => double.Parse(v.Lat)).Max();
            var maxLon = self.Select(v => double.Parse(v.Lon)).Max();

            return new Bounds(
                southWest: new Position(minLat, minLon),
                northEast: new Position(maxLat, maxLon)
            );
        } 
    }
}

