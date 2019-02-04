using Acr.UserDialogs;
using Plugin.Connectivity;
using Plugin.Geolocator;
using Plugin.Geolocator.Abstractions;
using Plugin.Permissions;
using Plugin.Permissions.Abstractions;
using ReactiveUI;
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
    public class RadiusViewModel : BaseVehicleLoadingViewModel, IVehiclesLoadedHandler
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

        private bool retrievingLocationInProgress = false;
        protected bool RetrievingLocationInProgress
        {
            get { return retrievingLocationInProgress; }
            set { this.RaiseAndSetIfChanged(ref retrievingLocationInProgress, value); }
        }

        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

        public RadiusViewModel(
            IScheduler mainThreadScheduler = null,
            IScheduler taskPoolScheduler = null,
            IVehiclesService vehiclesSevice = null,
            IScreen hostScreen = null
        ) : base(mainThreadScheduler, taskPoolScheduler, vehiclesSevice, hostScreen)
        {
            this.WhenActivated(disposables =>
            {
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
                        if (tuple.Item2 != PermissionStatus.Granted && await CrossPermissions.Current.ShouldShowRequestPermissionRationaleAsync(Permission.Location))
                        {
                            UserDialogs.Instance.Alert(new AlertConfig()
                            {
                                Title = "Location",
                                Message = "Need permissions to access device location."
                            });
                        }
                    })
                    .SelectMany(tuple =>
                    {
                        if (tuple.Item2 != PermissionStatus.Granted)
                        {
                            return CrossPermissions.Current.RequestPermissionsAsync(new[] { Permission.Location })
                                .ToObservable()
                                .Zip(
                                    second: Observable.Return(tuple.Item1),
                                    resultSelector: (results, distance) => new Tuple<Distance, PermissionStatus>(distance, results[Permission.Location])
                                );
                        }
                        else
                        {
                            return Observable.Return(tuple);
                        }
                    })
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
                            UserDialogs.Instance.Toast("Error retrieving location - device does not support geolocation.");
                            SelectedDistance = null;
                        }
                    })
                    .Where(_ => CrossGeolocator.IsSupported && CrossGeolocator.Current.IsGeolocationAvailable)
                    .Do(_ =>
                    {
                        if (!CrossGeolocator.Current.IsGeolocationEnabled)
                        {
                            //TODO: when this appears it looks like observable is disposed for some reason
                            Device.BeginInvokeOnMainThread(() =>
                            {
                                SelectedDistance = null;
                                UserDialogs.Instance.Toast("Error retrieving location - location is disabled.");
                            });
                        }
                    })
                    .Where(_ => CrossGeolocator.Current.IsGeolocationEnabled)
                    .SubscribeOn(this.mainThreadScheduler)
                    .ObserveOn(this.taskPoolScheduler)
                    .Do(_ => { RetrievingLocationInProgress = true; })
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
                        RetrievingLocationInProgress = false;
                        if (tuple.Item2 == null)
                        {
                            UserDialogs.Instance.Toast("Unable to retrieve device location.");
                            SelectedDistance = null;
                        }
                    })
                    .Where(tuple => tuple.Item2 != null)
                    .Do(_ => { LoadingVehiclesInProgress = true; })
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
                    .Do(_ => { LoadingVehiclesInProgress = false; })
                    .Subscribe(
                        onNext: (args) =>
                        {
                            if (args.Vehicles == null || !args.Vehicles.Any())
                            {
                                SelectedDistance = null;
                                OnVehiclesDataLoadingFailure();
                            }
                            else
                            {
                                OnVehiclesLoaded?.Invoke(this, args);
                                NavigateBack().Subscribe().DisposeWith(disposables);
                            }
                        },
                        onError: (error) =>
                        {
                            SelectedDistance = null;
                            OnVehiclesDataLoadingFailure();
                        })
                    .DisposeWith(disposables);

                this.WhenAnyValue(vm => vm.RetrievingLocationInProgress)
                  .Skip(1)
                  .DistinctUntilChanged()
                  .SubscribeOn(this.mainThreadScheduler)
                  .ObserveOn(this.mainThreadScheduler)
                  .Subscribe(isLoading =>
                  {
                      if (isLoading) UserDialogs.Instance.ShowLoading("Retrieving device location...");
                      else UserDialogs.Instance.HideLoading();
                  })
                  .DisposeWith(disposables);
            });
        }
    }
}
