using ReactiveUI;
using Splat;
using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Reactive;
using System.Reactive.Concurrency;
using System.Reactive.Disposables;
using System.Reactive.Linq;
using System.Windows.Input;
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

        private Location selectedLocation;
        public Location SelectedLocation
        {
            get { return selectedLocation; }
            set { this.RaiseAndSetIfChanged(ref selectedLocation, value); }
        }

        public ICommand GoToChooseRadius => ReactiveCommand.CreateFromObservable<Location, Unit>(location =>
        {
            var vm = new ChooseRadiusViewModel(location);
            vm.OnVehiclesLoaded += OnVehiclesLoaded;
            NavigateTo(vm).Subscribe();
            return Observable.Return(Unit.Default);
        });

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

            this.WhenActivated((CompositeDisposable disposables) =>
            {
                SelectedLocation = null;

                Observable.FromAsync(this.db.GetAllLocations)
                    .SubscribeOn(this.taskPoolScheduler)
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

                this.WhenAnyValue(vm => vm.SelectedLocation)
                    .SubscribeOn(this.mainThreadScheduler)
                    .ObserveOn(this.mainThreadScheduler)
                    .Where(location => location != null)
                    .Subscribe(location =>
                    {
                        GoToChooseRadius.Execute(location);
                    })
                    .DisposeWith(disposables);
            });
        }
    }
}
