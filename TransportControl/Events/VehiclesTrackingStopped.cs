using System;

namespace TransportControl.Events
{
    interface IVehiclesTrackingStoppedHandler
    {
        event EventHandler<VehiclesTrackingStoppedEventArgs> OnVehiclesTrackingStopped;
    }

    public class VehiclesTrackingStoppedEventArgs : EventArgs
    {
    }
}
