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
using TransportControl.Events;
using TransportControl.Models;
using TransportControl.Services;
using Xamarin.Forms;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace TransportControl.ViewModels
{
    public class ChooseRadiusViewModel : BaseVehicleLoadingViewModel, IVehiclesLoadedHandler
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

        private IObservable<Distance> SelectedDistanceObservable => this.WhenAnyValue(vm => vm.SelectedDistance)
            .Where(distance => distance != null)
            .Do(_ =>
            {
                Device.BeginInvokeOnMainThread(() =>
                {
                    if (!CrossConnectivity.Current.IsConnected)
                    {
                        SelectedDistance = null;
                        UserDialogs.Instance.Toast("Unable to load vehicles' data - no internet connection.");
                    }
                });
            })
            .Where(_ => CrossConnectivity.Current.IsConnected)
            .Do(_ => { Device.BeginInvokeOnMainThread(() => { SelectedDistance = null; }); });

        public ChooseRadiusViewModel(
            Location location,
            IScheduler mainThreadScheduler = null,
            IScheduler taskPoolScheduler = null,
            IVehiclesService vehiclesSevice = null,
            IScreen hostScreen = null
        ) : base(mainThreadScheduler, taskPoolScheduler, vehiclesSevice, hostScreen)
        {
            this.WhenActivated(disposables =>
            {
                SelectedDistance = null;
                SelectedDistanceObservable.Subscribe(onNext: async distance =>
                {
                    await LoadNearbyVehicles(distance, location.Position);
                })
                .DisposeWith(disposables);
            });
        }

        public ChooseRadiusViewModel(
            IScheduler mainThreadScheduler = null,
            IScheduler taskPoolScheduler = null,
            IVehiclesService vehiclesSevice = null,
            IScreen hostScreen = null
        ) : base(mainThreadScheduler, taskPoolScheduler, vehiclesSevice, hostScreen)
        {
            this.WhenActivated(disposables =>
            {
                SelectedDistance = null;

                this.WhenAnyValue(vm => vm.RetrievingLocationInProgress)
                  .Skip(1)
                  .DistinctUntilChanged()
                  .Subscribe(isLoading =>
                  {
                      if (isLoading) UserDialogs.Instance.ShowLoading("Retrieving device location...");
                      else UserDialogs.Instance.HideLoading();
                  })
                  .DisposeWith(disposables);

                SelectedDistanceObservable.Subscribe(onNext: async distance =>
                {
                    if (!await IsLocationPermissionGranted())
                    {
                        UserDialogs.Instance.Toast("Unable to load vehicles' data - no permission to access device location.");
                        return;
                    }

                    if (!CrossGeolocator.IsSupported || !CrossGeolocator.Current.IsGeolocationAvailable)
                    {
                        UserDialogs.Instance.Toast("Error retrieving location - device does not support geolocation.");
                        return;
                    }

                    if (!CrossGeolocator.Current.IsGeolocationEnabled)
                    {
                        UserDialogs.Instance.Toast("Error retrieving location - location is disabled.");
                        return;
                    }

                    var userLocation = await GetLastUserLocation();
                    if (userLocation == null)
                    {
                        UserDialogs.Instance.Toast("Unable to retrieve device location.");
                        return;
                    }

                    await LoadNearbyVehicles(distance, userLocation);
                })
                .DisposeWith(disposables);
            });
        }

        private async Task<bool> IsLocationPermissionGranted()
        {
            var status = await CrossPermissions.Current.CheckPermissionStatusAsync(Permission.Location);
            if (status == PermissionStatus.Granted)
            {
                return true;
            }
            else
            {
                var result = await CrossPermissions.Current.RequestPermissionsAsync(new[] { Permission.Location });
                return result[Permission.Location] == PermissionStatus.Granted;
            }
        }

        private async Task<Position> GetLastUserLocation()
        {
            RetrievingLocationInProgress = true;

            var lastKnownLocation = await CrossGeolocator.Current.GetLastKnownLocationAsync();
            if (lastKnownLocation == null)
            {
                try
                {
                    lastKnownLocation = await CrossGeolocator.Current.GetPositionAsync(TimeSpan.FromSeconds(15), null, true);
                }
                catch (TaskCanceledException e)
                {
                    return null;
                }
            }
            RetrievingLocationInProgress = false;
            return lastKnownLocation;
        }

        private async Task LoadNearbyVehicles(Distance distance, Position userLocation)
        {
            LoadingVehiclesInProgress = true;

            var args = await vehiclesSevice.FetchNearbyVehicles(distance, userLocation)
                .SelectMany(vehicles => Observable.Return(vehicles)
                    .Zip(
                        second: vehiclesSevice.LoadLinesWithSymbols(vehicles.Select(v => v.Number)),
                        resultSelector: (_, lines) => new VehiclesLoadedEventArgs(vehicles, lines)
                    )
                )
                .OnErrorResumeNext(Observable.Return(new VehiclesLoadedEventArgs(new List<Vehicle> { }, new List<Line> { }, true)))
                .FirstAsync();

            LoadingVehiclesInProgress = false;

            if (args.ErrorOccurred)
            {
                OnVehiclesDataLoadingFailure();
            }
            else if (args.Vehicles == null || !args.Vehicles.Any())
            {
                OnVehiclesDataLoadingFailure("No vehicles found within given radius.");
            }
            else
            {
                OnVehiclesLoaded?.Invoke(this, args);
                NavigateBack().Subscribe();
            }
        }
    }
}
