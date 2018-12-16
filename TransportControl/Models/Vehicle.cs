using Newtonsoft.Json;
using System.Globalization;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl.Models
{
    public class Vehicle
    {
        [JsonProperty("Lat")]
        public string Lat { get; set; }

        [JsonProperty("Lines")]
        public string Number { get; set; }

        [JsonProperty("Brigade")]
        public string Brigade { get; set; }

        [JsonProperty("Time")]
        public string Time { get; set; }

        [JsonProperty("Lon")]
        public string Lon { get; set; }

        [JsonIgnore]
        public int NumberInt => int.Parse(Number);

        [JsonIgnore]
        public double LatDbl => double.Parse(Lat, CultureInfo.GetCultureInfo("en-US"));

        [JsonIgnore]
        public double LonDbl => double.Parse(Lon, CultureInfo.GetCultureInfo("en-US"));

        [JsonIgnore]
        public Pin Pin { get; set; }

        [JsonIgnore]
        public bool ContainsAllInfo => Lat != null && Lon != null && Brigade != null && Number != null && Time != null;
    }
}
