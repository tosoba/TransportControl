using System;
using TransportControl.Events;

namespace TransportControl.ViewModels
{
    public class LinesTabbedViewModel : BaseViewModel
    {
        public Action<object, VehiclesLoadedEventArgs> OnVehiclesLoaded { get; set; }

        public AllLinesViewModel AllLinesViewModel
        {
            get
            {
                var vm = new AllLinesViewModel();
                vm.OnVehiclesLoaded += _OnVehiclesLoaded;
                return vm;
            }
        }

        public FavouriteLinesViewModel FavouriteLinesViewModel
        {
            get
            {
                var vm = new FavouriteLinesViewModel();
                vm.OnVehiclesLoaded += _OnVehiclesLoaded;
                return vm;
            }
        }

        private void _OnVehiclesLoaded(object sender, VehiclesLoadedEventArgs e) => OnVehiclesLoaded?.Invoke(sender, e);
    }
}
