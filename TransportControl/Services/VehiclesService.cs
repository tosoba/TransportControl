using Newtonsoft.Json.Linq;
using Refit;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reactive.Linq;
using System.Reflection;
using TransportControl.Api;
using TransportControl.Models;

namespace TransportControl.Services
{
    public class VehiclesService : IVehiclesService
    {
        private const string apiBaseAddress = "https://api.um.warszawa.pl/api/action";

        private IVehiclesApiClient client = RestService.For<IVehiclesApiClient>(apiBaseAddress);

        public IObservable<List<Vehicle>> FetchVehicles(int type, string line = null)
        {
            if (line == null) return client.FetchAllVehiclesOfType(type).Select(response => response.Result);
            else return client.FetchAllVehiclesOfTypeAndLine(type, line).Select(response => response.Result);
        }

        public IObservable<List<Line>> LoadLines()
        {
            var assembly = IntrospectionExtensions.GetTypeInfo(typeof(App)).Assembly;
            var stream = assembly.GetManifestResourceStream("TransportControl.Resources.lines.json");
            return Observable.Return(JArray.Parse(new StreamReader(stream).ReadToEnd()).Select(jsonLine => new Line
            {
                Symbol = jsonLine.Value<string>("Symbol"),
                Dest1 = jsonLine.Value<string>("Dest1"),
                Dest2 = jsonLine.Value<string>("Dest2")
            }).ToList());
        }

        public IObservable<List<Line>> LoadLinesWithSymbols(IEnumerable<string> symbols) => LoadLines()
                .SelectMany(lines => lines.ToObservable())
                .Where(line => symbols.Contains(line.Symbol))
                .ToList()
                .Select(lines => lines.ToList());
    }
}
