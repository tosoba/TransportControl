using Plugin.Connectivity;
using Plugin.Connectivity.Abstractions;
using ReactiveUI;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reactive.Concurrency;
using System.Reactive.Linq;
using System.Windows.Input;
using TransportControl.Events;
using TransportControl.MapPin;
using TransportControl.Models;
using TransportControl.Services;
using Xamarin.Forms;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl.ViewModels
{
    public class MapViewModel : BaseViewModel, IBoundsCalculatedHandler, IVehicleTrackingStartedHandler, IVehiclesTrackingStoppedHandler
    {
        public ICommand ClearMap { get; }
        public ICommand GoToLines { get; }
        public ICommand GoToRadius { get; }

        private bool isConnected = false;

        public event EventHandler<BoundsCalculatedEventArgs> OnBoundsCalculated;
        public event EventHandler<VehicleTrackingStartedEventArgs> OnVehicleTrackingStarted;
        public event EventHandler<VehiclesTrackingStoppedEventArgs> OnVehiclesTrackingStopped;

        public bool IsConnected
        {
            get { return isConnected; }
            private set { this.RaiseAndSetIfChanged(ref isConnected, value); }
        }

        private List<Vehicle> trackedVehicles = new List<Vehicle>();
        private List<Line> trackedLines = new List<Line>();

        private bool isRunning = false;
        public bool IsRunning
        {
            get => isRunning;
            set
            {
                isRunning = value;
                if (isRunning == false)
                {
                    trackedVehicles.Clear();
                    trackedLines.Clear();
                    OnVehiclesTrackingStopped?.Invoke(this, new VehiclesTrackingStoppedEventArgs());
                }
            }
        }

        //TODO: maybe inject this?
        private IVehiclesService vehiclesSevice;

        private IScheduler mainThreadScheduler;
        private IScheduler taskPoolScheduler;

        public MapViewModel(IScheduler mainThreadScheduler = null, IScheduler taskPoolScheduler = null, IScreen hostScreen = null) : base(hostScreen)
        {
            this.mainThreadScheduler = mainThreadScheduler ?? RxApp.MainThreadScheduler;
            this.taskPoolScheduler = taskPoolScheduler ?? RxApp.TaskpoolScheduler;
            vehiclesSevice = new VehiclesService();

            ClearMap = new Command(() => { IsRunning = false; });

            GoToLines = ReactiveCommand.CreateFromObservable(() =>
            {
                var vm = new LinesViewModel();
                vm.OnVehiclesLoaded += OnVehiclesLoaded;
                return NavigateTo(vm);
            });

            GoToRadius = ReactiveCommand.CreateFromObservable(() =>
            {
                var vm = new RadiusViewModel();
                vm.OnVehiclesLoaded += OnVehiclesLoaded;
                return NavigateTo(vm);
            });

            IsConnected = CrossConnectivity.Current.IsConnected;
            CrossConnectivity.Current.ConnectivityChanged += OnConnectivityChanged;
        }

        private void OnVehiclesLoaded(object sender, VehiclesLoadedEventArgs e)
        {
            var filteredVehicles = e.Vehicles.Where(v => v.ContainsAllInfo && !IsVehicleAdded(v))
                .ToList();
            if (filteredVehicles.Count > 0)
            {
                trackedLines.AddRange(e.Lines.Where(l => !IsLineAdded(l)));
                filteredVehicles.ForEach(v =>
                {
                    trackedVehicles.Add(v);
                    OnVehicleTrackingStarted?.Invoke(this, new VehicleTrackingStartedEventArgs(v));
                });

                StartUpdatesIfNotRunning();

                var bounds = filteredVehicles.GetBounds();
                OnBoundsCalculated?.Invoke(this, new BoundsCalculatedEventArgs(bounds));
            }
        }

        private void OnConnectivityChanged(object sender, ConnectivityChangedEventArgs e)
        {
            IsConnected = e.IsConnected;
        }

        private bool IsLineAdded(Line line) => trackedLines.Any(l => l.Symbol == line.Symbol);

        private bool IsVehicleAdded(Vehicle vehicle) => trackedVehicles.Any(v => v.Number == vehicle.Number && v.Brigade == vehicle.Brigade);

        private Vehicle Find(Vehicle vehicle) => trackedVehicles.Where(v => v.Number == vehicle.Number && v.Brigade == vehicle.Brigade)
            .FirstOrDefault();
        
        private void UpdateVehicle(Vehicle trackedVehicle, Vehicle loadedVehicle)
        {
            trackedVehicle.Lat = loadedVehicle.Lat;
            trackedVehicle.Lon = loadedVehicle.Lon;
            trackedVehicle.Time = loadedVehicle.Time;
            trackedVehicle.Pin.MoveTo(
                new Position(trackedVehicle.LatDbl, trackedVehicle.LonDbl)
            );
            trackedVehicle.Pin.UpdateLabel($"Last update at: {trackedVehicle.Time}");
        }

        private void StartUpdatesIfNotRunning()
        {
            if (!IsRunning)
            {
                //TODO: dipose this
                Observable.Interval(TimeSpan.FromSeconds(5))
                    .Where(_ => CrossConnectivity.Current.IsConnected)
                    .SelectMany(_ => trackedLines.ToObservable())
                    .SelectMany(line => vehiclesSevice.FetchVehicles(line.Type, line.Symbol))
                    .SubscribeOn(taskPoolScheduler)
                    .ObserveOn(mainThreadScheduler)
                    .Subscribe(vehiclesOfLine => 
                    {
                        vehiclesOfLine.ForEach(v => 
                        {
                            var trackedVehicle = Find(v);
                            if (trackedVehicle != null)
                            {
                                UpdateVehicle(trackedVehicle, v);
                            }
                        });
                    });

                IsRunning = true;
            }
        }
    }
}
