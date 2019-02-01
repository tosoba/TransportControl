using System;
using TransportControl.Models;

namespace TransportControl.Events
{
    public interface IVehicleTrackingStartedHandler
    {
        event EventHandler<VehicleTrackingStartedEventArgs> OnVehicleTrackingStarted;
    }

    public class VehicleTrackingStartedEventArgs : EventArgs
    {
        public Vehicle Vehicle { get; }

        public VehicleTrackingStartedEventArgs(Vehicle vehicle)
        {
            Vehicle = vehicle;
        }
    }
}
