using System;
using System.Collections.Generic;
using System.Text;
using TransportControl.Events;

namespace TransportControl.ViewModels
{
    public class FavouriteLocationsViewModel : BaseVehicleLoadingViewModel, IVehiclesLoadedHandler
    {
        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;
    }
}
