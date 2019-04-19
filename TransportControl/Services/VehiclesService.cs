using Newtonsoft.Json.Linq;
using Plugin.Geolocator.Abstractions;
using Refit;
using Splat;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reactive.Linq;
using System.Threading.Tasks;
using TransportControl.Api;
using TransportControl.Db;
using TransportControl.Models;
using TransportControl.Utils.Extensions;

namespace TransportControl.Services
{
    public class VehiclesService : IVehiclesService
    {
        private const string apiBaseAddress = "https://api.um.warszawa.pl/api/action";

        private IVehiclesApiClient client = RestService.For<IVehiclesApiClient>(apiBaseAddress);

        private IAppDatabase db;

        public VehiclesService(IAppDatabase db = null)
        {
            this.db = db ?? Locator.Current.GetService<IAppDatabase>();
        }

        public async Task<bool> AddToFavourites(Line line) => await db.InsertLine(line);

        public IObservable<List<Vehicle>> FetchNearbyVehicles(Distance distance, Position userLocation) => FetchVehicles(1)
                .Zip(
                    second: FetchVehicles(2),
                    resultSelector: (buses, trams) => buses.Concat(trams)
                )
                .SelectMany(vehicles => vehicles.ToObservable())
                .Where(vehicle => Coordinates.FromPosition(userLocation).DistanceTo(
                    targetCoordinates: Coordinates.FromPosition(new Position()
                    {
                        Latitude = vehicle.LatDbl,
                        Longitude = vehicle.LonDbl
                    }),
                    unitOfLength: UnitOfLength.Meters
                ) <= distance.Value)
                .ToList()
                .Select(vehicles => vehicles.ToList());

        public IObservable<List<Vehicle>> FetchVehicles(int type, string line = null)
        {
            if (line == null) return client.FetchAllVehiclesOfType(type).Select(response => response.Result);
            else return client.FetchAllVehiclesOfTypeAndLine(type, line).Select(response => response.Result);
        }

        public async Task<IEnumerable<Line>> GetFavouriteLines() => await db.GetAllLines();

        public IObservable<List<Line>> LoadLines()
        {
            return Observable.Return(JArray.Parse(new StreamReader("TransportControl.Resources.lines.json".ResourceStream()).ReadToEnd())
                .Select(jsonLine => new Line
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

        public async Task RemoveFromFavourites(Line line) => await db.DeleteLine(line);
    }
}
