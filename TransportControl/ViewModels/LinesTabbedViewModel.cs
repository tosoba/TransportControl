using System;
using TransportControl.Events;

namespace TransportControl.ViewModels
{
    public class LinesTabbedViewModel : BaseViewModel
    {
        public Action<object, VehiclesLoadedEventArgs> OnVehiclesLoaded { get; set; }

        public LinesViewModel LinesViewModel
        {
            get
            {
                var vm = new LinesViewModel();
                vm.OnVehiclesLoaded += _OnVehiclesLoaded;
                return vm;
            }
        }

        public FavouriteLinesViewModel FavouriteLinesViewModel => new FavouriteLinesViewModel();

        private void _OnVehiclesLoaded(object sender, VehiclesLoadedEventArgs e)
        {
            OnVehiclesLoaded?.Invoke(sender, e);
        }
    }
}
