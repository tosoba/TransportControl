using Plugin.Geolocator.Abstractions;
using System;

namespace TransportControl
{
    public class Coordinates
    {
        public double Latitude { get; private set; }
        public double Longitude { get; private set; }

        public Coordinates(double latitude, double longitude)
        {
            Latitude = latitude;
            Longitude = longitude;
        }

        public static Coordinates FromPosition(Position position) => new Coordinates(position.Latitude, position.Longitude);

        public static Coordinates FromMapPosition(Xamarin.Forms.GoogleMaps.Position position) => new Coordinates(position.Latitude, position.Longitude);
    }

    public static class CoordinatesDistanceExtensions
    {
        public static double DistanceTo(this Coordinates baseCoordinates, Coordinates targetCoordinates, UnitOfLength unitOfLength)
        {
            var baseRad = Math.PI * baseCoordinates.Latitude / 180;
            var targetRad = Math.PI * targetCoordinates.Latitude / 180;
            var theta = baseCoordinates.Longitude - targetCoordinates.Longitude;
            var thetaRad = Math.PI * theta / 180;

            double dist =
                Math.Sin(baseRad) * Math.Sin(targetRad) + Math.Cos(baseRad) *
                Math.Cos(targetRad) * Math.Cos(thetaRad);
            dist = Math.Acos(dist);

            dist = dist * 180 / Math.PI;
            dist = dist * 60 * 1.1515;

            return unitOfLength.ConvertFromMiles(dist);
        }
    }

    public class UnitOfLength
    {
        public static UnitOfLength Kilometers = new UnitOfLength(1.609344);
        public static UnitOfLength Meters = new UnitOfLength(1609.344);
        public static UnitOfLength NauticalMiles = new UnitOfLength(0.8684);
        public static UnitOfLength Miles = new UnitOfLength(1);

        private readonly double fromMilesFactor;

        private UnitOfLength(double fromMilesFactor)
        {
            this.fromMilesFactor = fromMilesFactor;
        }

        public double ConvertFromMiles(double input) => input * fromMilesFactor;
    }

}
