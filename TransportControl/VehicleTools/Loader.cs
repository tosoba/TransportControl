using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using TransportControl.Models;
using System.Linq;

namespace TransportControl
{
    public static class LinesLoader
    {
        //TODO: move this to VehiclesService
        public static List<Line> Load()
        {
            var assembly = IntrospectionExtensions.GetTypeInfo(typeof(LinesLoader)).Assembly;
            Stream stream = assembly.GetManifestResourceStream("TransportControl.Resources.lines.json");
            string text = string.Empty;
            using (var reader = new StreamReader(stream))
            {
                text = reader.ReadToEnd();
            }
            return JArray.Parse(text).Select(jsonLine => new Line
            {
                Symbol = jsonLine.Value<string>("Symbol"),
                Dest1 = jsonLine.Value<string>("Dest1"),
                Dest2 = jsonLine.Value<string>("Dest2")
            }).ToList();
        }
    }
}
