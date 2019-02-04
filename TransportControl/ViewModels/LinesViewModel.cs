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
using Plugin.Connectivity;
using Acr.UserDialogs;
using Xamarin.Forms;
using MoreLinq;

namespace TransportControl.ViewModels
{
    public class LinesViewModel : BaseVehicleLoadingViewModel, IVehiclesLoadedHandler
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

        public int LineCount => AllLines.Count;

        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

        public LinesViewModel(
            IScheduler mainThreadScheduler = null,
            IScheduler taskPoolScheduler = null,
            IVehiclesService vehiclesSevice = null,
            IScreen hostScreen = null
        ) : base(mainThreadScheduler, taskPoolScheduler, vehiclesSevice, hostScreen)
        {
            this.WhenActivated(disposables =>
            {
                SelectedLine = null;

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
                    .Do(_ => { LoadingVehiclesInProgress = true; })
                    .SelectMany(line => this.vehiclesSevice.FetchVehicles(line.Type, line.Symbol)
                        .Select(vehicles => new VehiclesLoadedEventArgs(vehicles, new List<Line> { line }))
                    )
                    .SubscribeOn(this.taskPoolScheduler)
                    .ObserveOn(this.mainThreadScheduler)
                    .Do(_ => { LoadingVehiclesInProgress = false; })
                    .Subscribe(
                        onNext: args =>
                        {
                            if (args.Vehicles == null || !args.Vehicles.Any())
                            {
                                OnVehiclesDataLoadingFailure("API returned no results.");
                            }
                            else
                            {
                                OnVehiclesLoaded?.Invoke(this, args);
                                NavigateBack().Subscribe().DisposeWith(disposables);
                            }
                        },
                        onError: error =>
                        {
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
            });
        }

        public Line FindBy(string symbol) => AllLines.Where(l => l.Symbol == symbol).FirstOrDefault();

        private void FilterLines(string filter)
        {
            if (!filter.Trim().Any())
                GroupLines(AllLines);
            else
            {
                var filteredLines = AllLines.Where(l => l.Symbol.ToLower().Contains(filter.ToLower())).ToList();
                GroupLines(filteredLines);
            }
        }

        private void GroupLines(List<Line> lines)
        {
            LinesGrouped?.Clear();
            var groups = lines.GroupBy(l => l.GroupSymbol)
                 .Select(lg => new GroupedObservableCollection<string, Line>(lg.Key, lg));
            if (!groups.Any())
                LinesGrouped = new ObservableCollection<GroupedObservableCollection<string, Line>>();
            else
            {
                var dividedGroups = groups.Partition(lg => lg.Key.All(char.IsDigit)).ToTuple();
                var numberOnlyLines = dividedGroups.Item1
                    .Select(lg => new GroupedObservableCollection<string, Line>(lg.Key, lg.OrderBy(l => int.Parse(l.Symbol))));
                var linesContainingLetters = dividedGroups.Item2
                    .Select(lg => new GroupedObservableCollection<string, Line>(lg.Key, lg.OrderBy(l => l.Symbol)));
                LinesGrouped = new ObservableCollection<GroupedObservableCollection<string, Line>>(numberOnlyLines.Concat(linesContainingLetters));
            }
        }
    }
}
