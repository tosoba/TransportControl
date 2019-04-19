using ReactiveUI;
using Splat;
using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Reactive.Concurrency;
using System.Reactive.Disposables;
using System.Reactive.Linq;
using TransportControl.Db;
using TransportControl.Events;
using TransportControl.Models;

namespace TransportControl.ViewModels
{
    public class FavouriteLocationsViewModel : BaseVehicleLoadingViewModel, IVehiclesLoadedHandler
    {
        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

        private ObservableCollection<Location> locations;
        public ObservableCollection<Location> Locations
        {
            get => locations;
            set
            {
                this.RaiseAndSetIfChanged(ref locations, value);
                this.RaisePropertyChanged("NoLocationsLabelVisible");
            }
        }

        public Location SelectedLocation { get; set; }

        public bool NoLocationsLabelVisible => Locations == null || !Locations.Any();

        private IAppDatabase db;

        public FavouriteLocationsViewModel(
            IAppDatabase db = null,
            IScheduler mainThreadScheduler = null,
            IScheduler taskPoolScheduler = null)
        {
            this.db = db ?? Locator.Current.GetService<IAppDatabase>();
            this.mainThreadScheduler = mainThreadScheduler ?? RxApp.MainThreadScheduler;
            this.taskPoolScheduler = taskPoolScheduler ?? RxApp.TaskpoolScheduler;

            this.db.InsertLocation(new Location()
            {
                Name = "WAW test",
                Lat = 52.19,
                Lon = 21
            });

            this.WhenActivated((CompositeDisposable disposables) =>
            {
                Observable.FromAsync(this.db.GetAllLocations)
                    .SubscribeOn(this.mainThreadScheduler)
                    .ObserveOn(this.mainThreadScheduler)
                    .Subscribe(
                    onNext: (locations) =>
                    {
                        Locations = new ObservableCollection<Location>(locations);
                    },
                    onError: (err) =>
                    {
                    })
                    .DisposeWith(disposables);
            });
        }
    }
}
