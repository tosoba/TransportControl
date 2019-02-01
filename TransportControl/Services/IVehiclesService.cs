using System;
using System.Collections.Generic;
using TransportControl.Models;

namespace TransportControl.Services
{
    public interface IVehiclesService
    {
        IObservable<List<Vehicle>> FetchVehicles(int type, string line = null);
    }
}
