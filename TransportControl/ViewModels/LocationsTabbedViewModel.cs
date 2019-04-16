using ReactiveUI;
using System;
using System.Windows.Input;
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

        public ICommand GoToRadius { get; }

        public LocationsTabbedViewModel()
        {
            GoToRadius = ReactiveCommand.CreateFromObservable(() =>
            {
                var vm = new ChooseRadiusViewModel();
                vm.OnVehiclesLoaded += _OnVehiclesLoaded;
                return NavigateTo(vm);
            });
        }

        private void _OnVehiclesLoaded(object sender, VehiclesLoadedEventArgs e)
        {
            OnVehiclesLoaded?.Invoke(sender, e);
            NavigateBack().Subscribe();
        }
    }
}
