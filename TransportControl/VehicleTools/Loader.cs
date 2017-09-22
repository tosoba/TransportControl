using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Reflection;
using System.Threading.Tasks;
using TransportControl.Models;

namespace TransportControl
{
    public class Loader
    {
        private static readonly string URL_COMMON = "https://api.um.warszawa.pl/api/action/busestrams_get/?resource_id=f2e5503e-927d-4ad3-9500-4ab9e55deb59&apikey=" + Keys.WARSAW_API_KEY;
        private static readonly string TYPE_BUS = "&type=1";
        private static readonly string TYPE_TRAM = "&type=2";
        private static readonly string LINE = "&line=";

        public JArray LoadLines()
        {
            var assembly = typeof(App).GetTypeInfo().Assembly;
            Stream stream = assembly.GetManifestResourceStream("TransportControl.Resources.lines.json");
            string text = String.Empty;
            using (var reader = new StreamReader(stream))
            {
                text = reader.ReadToEnd();
            }
            return JArray.Parse(text);
        }

        public async Task<List<Vehicle>> LoadVehicles(string number, int type)
        {
            string typeStr = type == 1 ? TYPE_BUS : TYPE_TRAM;
            using (var httpClient = new HttpClient())
            {
                var jsonStr = await httpClient.GetStringAsync(URL_COMMON + typeStr + LINE + number);
                return ParseVehicles(jsonStr);
            }
        }

        public async Task<List<Vehicle>> LoadAllVehiclesOfType(int type)
        {
            string typeStr = type == 1 ? TYPE_BUS : TYPE_TRAM;
            using (var httpClient = new HttpClient())
            {
                var jsonStr = await httpClient.GetStringAsync(URL_COMMON + typeStr);
                return ParseVehicles(jsonStr);
            }
        }

        private List<Vehicle> ParseVehicles(string jsonStr)
        {
            var vehicles = new List<Vehicle>();
            var json = JObject.Parse(jsonStr);
            JToken tokenResult;
            var success = json.TryGetValue("result", out tokenResult);
            if (success)
            {
                var result = tokenResult as JArray;
                if (result == null) return null;

                foreach (var j in result)
                {
                    vehicles.Add(new Vehicle
                    {
                        Lat = j.Value<string>("Lat"),
                        Lon = j.Value<string>("Lon"),
                        Brigade = j.Value<string>("Brigade"),
                        Number = j.Value<string>("Lines"),
                        Time = j.Value<string>("Time")
                    });
                }
                return vehicles;
            }
            else
            {
                return null;
            }
        }
    }
}
