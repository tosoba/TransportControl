using System;

namespace TransportControl
{
    public interface ILoadingPage
    {
        event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;
    }
}
