using Acr.UserDialogs;
using Plugin.Connectivity;
using Plugin.Geolocator;
using Plugin.Geolocator.Abstractions;
using Plugin.Permissions;
using Plugin.Permissions.Abstractions;
using ReactiveUI;
using Splat;
using System;
using System.Linq;
using System.Collections.ObjectModel;
using System.Reactive.Concurrency;
using System.Reactive.Disposables;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using TransportControl.Events;
using TransportControl.Models;
using TransportControl.Services;
using Xamarin.Forms;

namespace TransportControl.ViewModels
{
    public class RadiusViewModel : BaseViewModel, IVehiclesLoadedHandler
    {
        public ObservableCollection<Distance> Distances { get; set; } = new ObservableCollection<Distance>
        {
            new Distance(100),
            new Distance(250),
            new Distance(500),
            new Distance(1000),
            new Distance(2000),
            new Distance(5000),
            new Distance(10000)
        };

        private Distance selectedDistance;
        public Distance SelectedDistance
        {
            set { this.RaiseAndSetIfChanged(ref selectedDistance, value); }
            get { return selectedDistance; }
        }

        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

        private IVehiclesService vehiclesSevice;

        private IScheduler mainThreadScheduler;
        private IScheduler taskPoolScheduler;

        public RadiusViewModel(
            IScheduler mainThreadScheduler = null,
            IScheduler taskPoolScheduler = null,
            IVehiclesService vehiclesSevice = null,
            IScreen hostScreen = null
        ) : base(hostScreen)
        {
            //TODO: move this to an abstract base viewmodel class BaseVehicleLoadingViewModel
            this.mainThreadScheduler = mainThreadScheduler ?? RxApp.MainThreadScheduler;
            this.taskPoolScheduler = taskPoolScheduler ?? RxApp.TaskpoolScheduler;
            this.vehiclesSevice = vehiclesSevice ?? Locator.Current.GetService<IVehiclesService>();

            this.WhenActivated(disposables =>
            {
                //TODO: try to make this work somehow with both checking permissions and internet connection
                this.WhenAnyValue(vm => vm.SelectedDistance)
                    .Where(distance => distance != null)
                    .Do(_ =>
                    {
                        if (!CrossConnectivity.Current.IsConnected)
                        {
                            Device.BeginInvokeOnMainThread(() =>
                            {
                                UserDialogs.Instance.Toast("Unable to load vehicles' data - no internet connection.");
                                SelectedDistance = null;
                            });
                        }
                    })
                    .Where(_ => CrossConnectivity.Current.IsConnected)
                    .Zip(
                        second: CrossPermissions.Current.CheckPermissionStatusAsync(Permission.Location).ToObservable(),
                        resultSelector: (distance, permissionStatus) => new Tuple<Distance, PermissionStatus>(distance, permissionStatus)
                    )
                    .Do(async (tuple) =>
                    {
                        if (await CrossPermissions.Current.ShouldShowRequestPermissionRationaleAsync(Permission.Location))
                            Dialogs.ShowAlertDialog("Location", "Need permissions to access device location.");
                    })
                    .SelectMany(tuple => CrossPermissions.Current.RequestPermissionsAsync(new[] { Permission.Location })
                            .ToObservable()
                            .Zip(
                                second: Observable.Return(tuple.Item1),
                                resultSelector: (results, distance) => new Tuple<Distance, PermissionStatus>(distance, results[Permission.Location])
                            )
                    )
                    .Do(tuple =>
                    {
                        if (tuple.Item2 != PermissionStatus.Granted)
                        {
                            UserDialogs.Instance.Toast("Unable to load vehicles' data - no permission to access device location.");
                            SelectedDistance = null;
                        }
                    })
                    .Where(tuple => tuple.Item2 == PermissionStatus.Granted)
                    .Do(_ =>
                    {
                        if (!CrossGeolocator.IsSupported || !CrossGeolocator.Current.IsGeolocationAvailable)
                        {
                            Dialogs.ShowAlertDialog("Error retrieving location.", "Device does not support geolocation.");
                            SelectedDistance = null;
                        }
                    })
                    .Where(_ => CrossGeolocator.IsSupported && CrossGeolocator.Current.IsGeolocationAvailable)
                    .Do(_ =>
                    {
                        if (!CrossGeolocator.Current.IsGeolocationEnabled)
                        {
                            Dialogs.ShowAlertDialog("Error retrieving location.", "Location is disabled.");
                            SelectedDistance = null;
                        }
                    })
                    .Where(_ => CrossGeolocator.Current.IsGeolocationEnabled)
                    .SubscribeOn(this.mainThreadScheduler)
                    .ObserveOn(this.taskPoolScheduler)
                    .SelectMany(tuple => CrossGeolocator.Current.GetLastKnownLocationAsync()
                             .ToObservable()
                             .SelectMany(lastKnownLocation =>
                             {
                                 if (lastKnownLocation == null) return CrossGeolocator.Current.GetPositionAsync(TimeSpan.FromSeconds(15), null, true).ToObservable();
                                 else return Observable.Return(lastKnownLocation);
                             })
                             .Zip(
                                 second: Observable.Return(tuple.Item1),
                                 resultSelector: (location, distance) => new Tuple<Distance, Position>(distance, location)
                             )
                    )
                    .Do(tuple =>
                    {
                        if (tuple.Item2 == null)
                        {
                            UserDialogs.Instance.Toast("Unable to retrieve device location.");
                            SelectedDistance = null;
                        }
                    })
                    .Where(tuple => tuple.Item2 != null)
                    .SelectMany(tuple => this.vehiclesSevice.FetchVehicles(1)
                            .Zip(
                                second: this.vehiclesSevice.FetchVehicles(2),
                                resultSelector: (buses, trams) => buses.Concat(trams)
                            )
                            .SelectMany(vehicles => vehicles.ToObservable())
                            .Where(vehicle => Coordinates.FromPosition(tuple.Item2).DistanceTo(Coordinates.FromPosition(new Position()
                            {
                                Latitude = vehicle.LatDbl,
                                Longitude = vehicle.LonDbl
                            }), UnitOfLength.Meters) <= tuple.Item1.Value)
                            .ToList()
                            .Select(vehicles => vehicles.ToList())
                            .SelectMany(vehicles => Observable.Return(vehicles)
                                .Zip(
                                    second: this.vehiclesSevice.LoadLinesWithSymbols(vehicles.Select(v => v.Number)),
                                    resultSelector: (_, lines) => new VehiclesLoadedEventArgs(vehicles, lines)
                                )
                            )
                    )
                    .ObserveOn(this.mainThreadScheduler)
                    .Subscribe(
                        onNext: (args) =>
                        {
                            if (args.Vehicles == null || !args.Vehicles.Any())
                            {
                                //TODO: OnVehiclesDataLoadingFailure();
                            }
                            else
                            {
                                OnVehiclesLoaded?.Invoke(this, args);
                                NavigateBack().Subscribe().DisposeWith(disposables);
                            }
                        },
                        onError: (error) =>
                        {
                            //TODO:
                            //LoadingVehiclesInProgress = false;
                            //OnVehiclesDataLoadingFailure();
                        });
            });
        }
    }
}
