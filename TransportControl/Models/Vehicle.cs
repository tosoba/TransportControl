using Newtonsoft.Json;
using System;
using System.Globalization;
using TransportControl.Utils;
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
        [JsonConverter(typeof(JsonDateTimeConverter), "yyyy-MM-dd HH:mm:ss")]
        public DateTime Time { get; set; }

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

        [JsonIgnore]
        public string Label
        {
            get
            {
                TimeSpan timeSpanSinceUpdate = DateTime.Now - Time;
                string label = "Last updated: ";
                if (timeSpanSinceUpdate.Days > 0)
                {
                    label += timeSpanSinceUpdate.Days;
                    label += timeSpanSinceUpdate.Days > 1 ? " days ago" : " day ago";
                }
                else if (timeSpanSinceUpdate.Hours > 0)
                {
                    label += timeSpanSinceUpdate.Hours;
                    label += timeSpanSinceUpdate.Hours > 1 ? " hours ago" : " hour ago";
                }
                else if (timeSpanSinceUpdate.Minutes > 0)
                {
                    label += timeSpanSinceUpdate.Minutes;
                    label += timeSpanSinceUpdate.Minutes > 1 ? " minutes " : " minute ";
                    if (timeSpanSinceUpdate.Seconds == 0) label += "ago";
                    else
                    {
                        label += timeSpanSinceUpdate.Seconds;
                        label += timeSpanSinceUpdate.Seconds > 1 ? " seconds ago" : " second ago";
                    }
                }
                else if (timeSpanSinceUpdate.Seconds > 0)
                {
                    label += timeSpanSinceUpdate.Seconds;
                    label += timeSpanSinceUpdate.Seconds > 1 ? " seconds ago" : " second ago";
                }
                else
                {
                    label += "just now";
                }
                return label;
            }
        }
    }
}
