using Newtonsoft.Json;
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
            var assembly = IntrospectionExtensions.GetTypeInfo(typeof(Loader)).Assembly;
            Stream stream = assembly.GetManifestResourceStream("TransportControl.Resources.lines.json");
            string text = string.Empty;
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
                try
                {
                    var response = JsonConvert.DeserializeObject<VehiclesResponse>(jsonStr);
                    return response.Result;
                }
                catch (Exception)
                {
                    return null;
                }
            }
        }

        public async Task<List<Vehicle>> LoadAllVehiclesOfType(int type)
        {
            string typeStr = type == 1 ? TYPE_BUS : TYPE_TRAM;
            using (var httpClient = new HttpClient())
            {
                var jsonStr = await httpClient.GetStringAsync(URL_COMMON + typeStr);
                try
                {
                    var response = JsonConvert.DeserializeObject<VehiclesResponse>(jsonStr);
                    return response.Result;
                }
                catch (Exception)
                {
                    return null;
                }
            }
        }
    }
}
