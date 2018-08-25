using Xamarin.Forms.GoogleMaps;

namespace TransportControl.Models
{
    public class Vehicle
    {
        public string Lat { get; set; }
        public string Number { get; set; }
        public string Brigade { get; set; }
        public string Time { get; set; }
        public string Lon { get; set; }

        public int NumberInt => int.Parse(Number);
        public double LatDbl => double.Parse(Lat);
        public double LonDbl => double.Parse(Lon);

        public Pin Pin { get; set; }
    }
}
