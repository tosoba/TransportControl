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
        public bool ErrorOccurred { get; }

        public VehiclesLoadedEventArgs(List<Vehicle> vehicles, List<Line> lines, bool errorOccurred = false)
        {
            Vehicles = vehicles;
            Lines = lines;
            ErrorOccurred = errorOccurred;
        }
    }
}
