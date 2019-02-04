using System.Collections.Generic;
using System.Linq;
using TransportControl.Models;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl
{
    public static class ListExtensions
    { 
        public static Bounds GetBounds(this IList<Vehicle> self)
        {
            var minLat = self.Select(v => v.LatDbl).Min();
            var minLon = self.Select(v => v.LonDbl).Min();
            var maxLat = self.Select(v => v.LatDbl).Max();
            var maxLon = self.Select(v => v.LonDbl).Max();

            return new Bounds(
                southWest: new Position(minLat, minLon),
                northEast: new Position(maxLat, maxLon)
            );
        } 
    }
}

