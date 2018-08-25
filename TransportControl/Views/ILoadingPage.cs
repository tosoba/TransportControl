using System;

namespace TransportControl
{
    public interface IVehicleLoadingPage
    {
        event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;
    }
}
