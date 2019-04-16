using System;
using TransportControl.Events;

namespace TransportControl.ViewModels
{
    public class LocationsTabbedViewModel : BaseViewModel
    {
        public Action<object, VehiclesLoadedEventArgs> OnVehiclesLoaded { get; set; }

        public ChooseLocationViewModel ChooseLocationViewModel
        {
            get
            {
                var vm = new ChooseLocationViewModel();
                vm.OnVehiclesLoaded += _OnVehiclesLoaded;
                return vm;
            }
        }

        public FavouriteLocationsViewModel FavouriteLocationsViewModel
        {
            get
            {
                var vm = new FavouriteLocationsViewModel();
                vm.OnVehiclesLoaded += _OnVehiclesLoaded;
                return vm;
            }
        }

        private void _OnVehiclesLoaded(object sender, VehiclesLoadedEventArgs e) => OnVehiclesLoaded?.Invoke(sender, e);
    }
}
