using System.Collections.Generic;
using System.Linq;
using TransportControl.Models;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl
{
    public static class VehicleHelper
    {
        public static Bounds GetBounds(List<Vehicle> vehicles)
        {
            var minLat = vehicles.Select(v => double.Parse(v.Lat)).Min();
            var minLon = vehicles.Select(v => double.Parse(v.Lon)).Min();
            var maxLat = vehicles.Select(v => double.Parse(v.Lat)).Max();
            var maxLon = vehicles.Select(v => double.Parse(v.Lon)).Max();

            return new Bounds(
                southWest: new Position(minLat, minLon),
                northEast: new Position(maxLat, maxLon)
            );
        }
    }
}
