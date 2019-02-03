using System;
using System.Linq;
using System.Collections.ObjectModel;
using TransportControl.Events;
using TransportControl.List;
using TransportControl.Models;
using System.Collections.Generic;
using ReactiveUI;
using System.Reactive.Linq;
using TransportControl.Services;
using System.Reactive.Concurrency;
using System.Reactive.Disposables;
using Splat;
using Plugin.Connectivity;
using Acr.UserDialogs;
using Xamarin.Forms;

namespace TransportControl.ViewModels
{
    public class LinesViewModel : BaseViewModel, IVehiclesLoadedHandler
    {
        private List<Line> AllLines { get; set; }

        private ObservableCollection<GroupedObservableCollection<string, Line>> linesGrouped;
        public ObservableCollection<GroupedObservableCollection<string, Line>> LinesGrouped
        {
            get { return linesGrouped; }
            set { this.RaiseAndSetIfChanged(ref linesGrouped, value); }
        }

        private Line selectedLine;
        public Line SelectedLine
        {
            get { return selectedLine; }
            set { this.RaiseAndSetIfChanged(ref selectedLine, value); }
        }

        private string searchInput;
        public string SearchInput
        {
            get { return searchInput; }
            set { this.RaiseAndSetIfChanged(ref searchInput, value); }
        }

        private bool loadingVehiclesInProgress = false;
        public bool LoadingVehiclesInProgress
        {
            get { return loadingVehiclesInProgress; }
            set { this.RaiseAndSetIfChanged(ref loadingVehiclesInProgress, value); }
        }

        public int LineCount => AllLines.Count;

        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

        private IVehiclesService vehiclesSevice;

        private IScheduler mainThreadScheduler;
        private IScheduler taskPoolScheduler;

        public LinesViewModel(
            IScheduler mainThreadScheduler = null,
            IScheduler taskPoolScheduler = null,
            IVehiclesService vehiclesSevice = null,
            IScreen hostScreen = null
        ) : base(hostScreen)
        {
            this.mainThreadScheduler = mainThreadScheduler ?? RxApp.MainThreadScheduler;
            this.taskPoolScheduler = taskPoolScheduler ?? RxApp.TaskpoolScheduler;
            this.vehiclesSevice = vehiclesSevice ?? Locator.Current.GetService<IVehiclesService>();

            this.WhenActivated(disposables =>
            {
                this.WhenAnyValue(vm => vm.SelectedLine)
                    .Where(line => line != null)
                    .Do(_ =>
                    {
                        if (!CrossConnectivity.Current.IsConnected)
                        {
                            Device.BeginInvokeOnMainThread(() =>
                            {
                                UserDialogs.Instance.Toast("Unable to load vehicles' data - no internet connection.");
                                SelectedLine = null;
                            });
                        }
                    })
                    .Where(_ => CrossConnectivity.Current.IsConnected)
                    .Do(_ =>
                    {
                        LoadingVehiclesInProgress = true;
                    })
                    .SelectMany(line => this.vehiclesSevice.FetchVehicles(line.Type, line.Symbol)
                        .Select(vehicles => new VehiclesLoadedEventArgs(vehicles, new List<Line> { line }))
                    )
                    .SubscribeOn(this.taskPoolScheduler)
                    .ObserveOn(this.mainThreadScheduler)
                    .Subscribe(
                        onNext: args =>
                        {
                            LoadingVehiclesInProgress = false;
                            if (args.Vehicles == null || !args.Vehicles.Any())
                            {
                                OnVehiclesDataLoadingFailure();
                            }
                            else
                            {
                                OnVehiclesLoaded?.Invoke(this, args);
                                NavigateBack().Subscribe().DisposeWith(disposables);
                            }
                        },
                        onError: error =>
                        {
                            LoadingVehiclesInProgress = false;
                            OnVehiclesDataLoadingFailure();
                        })
                    .DisposeWith(disposables);

                this.WhenAnyValue(vm => vm.SearchInput)
                    .Where(input => input != null)
                    .DistinctUntilChanged()
                    .Subscribe(input =>
                    {
                        FilterLines(input);
                    })
                    .DisposeWith(disposables);

                this.vehiclesSevice.LoadLines()
                    .SubscribeOn(this.taskPoolScheduler)
                    .ObserveOn(this.mainThreadScheduler)
                    .Subscribe(lines =>
                    {
                        AllLines = lines;
                        GroupLines(AllLines);
                    })
                    .DisposeWith(disposables);

                this.WhenAnyValue(vm => vm.LoadingVehiclesInProgress)
                    .Skip(1)
                    .DistinctUntilChanged()
                    .SubscribeOn(this.mainThreadScheduler)
                    .ObserveOn(this.mainThreadScheduler)
                    .Subscribe(isLoading =>
                    {
                        //TODO: this is not working - maybe use another lib or smth...
                        if (isLoading) UserDialogs.Instance.Loading("Loading vehicles' data in progress...").Show();
                        else UserDialogs.Instance.HideLoading();
                    })
                    .DisposeWith(disposables);
            });
        }

        public Line FindBy(string symbol) => AllLines.Where(l => l.Symbol == symbol).FirstOrDefault();

        private void FilterLines(string filter)
        {
            if (!filter.Trim().Any())
                GroupLines(AllLines);
            else
            {
                var filteredLines = AllLines.Where(l => l.Symbol.ToLower().Contains(filter.ToLower()))
                    .ToList();
                GroupLines(filteredLines);
            }
        }

        private void GroupLines(List<Line> lines)
        {
            LinesGrouped?.Clear();

            var sorted = lines.OrderBy(l => l.Symbol)
                .GroupBy(l => l.SymbolSort)
                .Select(lg => new GroupedObservableCollection<string, Line>(lg.Key, lg));

            if (!sorted.Any()) LinesGrouped = new ObservableCollection<GroupedObservableCollection<string, Line>>();
            else
            {
                var first = sorted.First()
                    .OrderBy(l => int.Parse(l.Symbol))
                    .GroupBy(l => l.SymbolSort)
                    .Select(g => new GroupedObservableCollection<string, Line>(g.Key, g));
                var rest = sorted.Skip(1);

                LinesGrouped = new ObservableCollection<GroupedObservableCollection<string, Line>>(first.Concat(rest));
            }
        }

        private void OnVehiclesDataLoadingFailure()
        {
            UserDialogs.Instance.Toast("Unable to load vehicles' data.");
        }
    }
}
