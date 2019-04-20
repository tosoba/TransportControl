using Acr.UserDialogs;
using ReactiveUI;
using Splat;
using System;
using System.Reactive.Linq;
using System.Windows.Input;
using TransportControl.Db;
using TransportControl.Events;
using TransportControl.Models;

namespace TransportControl.ViewModels
{
    public class ChooseLocationViewModel : BaseVehicleLoadingViewModel, IVehiclesLoadedHandler
    {
        public ICommand AddToFavourites { get; }
        public ICommand GoToRadius { get; }

        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

        public Location ChosenLocation { get; set; }

        private IAppDatabase db;

        public ChooseLocationViewModel(IAppDatabase db = null)
        {
            this.db = db ?? Locator.Current.GetService<IAppDatabase>();

            GoToRadius = ReactiveCommand.CreateFromObservable(() =>
            {
                var vm = new ChooseRadiusViewModel(ChosenLocation);
                vm.OnVehiclesLoaded += OnVehiclesLoaded;
                return NavigateTo(vm);
            });

            AddToFavourites = ReactiveCommand.CreateFromObservable(() =>
            {
                return Observable.FromAsync(() => this.db.InsertLocation(ChosenLocation))
                    .SubscribeOn(RxApp.TaskpoolScheduler)
                    .ObserveOn(RxApp.MainThreadScheduler)
                    .Do(_ =>
                    {
                        UserDialogs.Instance.Toast($"{ChosenLocation.Name} added to favourites.");
                    });
            });
        }
    }
}
