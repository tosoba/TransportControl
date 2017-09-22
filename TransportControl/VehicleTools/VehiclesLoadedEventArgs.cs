using System;
using System.Collections.Generic;
using TransportControl.Models;

namespace TransportControl
{
    public class VehiclesLoadedEventArgs : EventArgs
    {
        public List<Vehicle> Vehicles { get; set; }
        public List<Line> Lines { get; set; }

        public VehiclesLoadedEventArgs(List<Vehicle> vehicles, List<Line> lines)
        {
            Vehicles = vehicles;
            Lines = lines;
        }
    }
}
