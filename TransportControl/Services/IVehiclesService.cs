using Plugin.Geolocator.Abstractions;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TransportControl.Models;

namespace TransportControl.Services
{
    public interface IVehiclesService
    {
        IObservable<List<Vehicle>> FetchVehicles(int type, string line = null);
        IObservable<List<Vehicle>> FetchNearbyVehicles(Distance distance, Position userLocation);
        IObservable<List<Line>> LoadLines();
        IObservable<List<Line>> LoadLinesWithSymbols(IEnumerable<string> symbols);
        Task<IEnumerable<Line>> GetFavouriteLines();
        Task<bool> AddToFavourites(Line line);
        Task RemoveFromFavourites(Line line);
    }
}
