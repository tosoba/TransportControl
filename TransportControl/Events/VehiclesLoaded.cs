using System;
using System.Collections.Generic;
using TransportControl.Models;

namespace TransportControl.Events
{
    public interface IVehiclesLoadedHandler
    {
        event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;
    }

    public class VehiclesLoadedEventArgs : EventArgs
    {
        public List<Vehicle> Vehicles { get; }
        public List<Line> Lines { get; }

        public VehiclesLoadedEventArgs(List<Vehicle> vehicles, List<Line> lines)
        {
            Vehicles = vehicles;
            Lines = lines;
        }
    }
}
