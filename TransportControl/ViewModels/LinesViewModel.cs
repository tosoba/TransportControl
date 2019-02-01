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

namespace TransportControl.ViewModels
{
    public class LinesViewModel : BaseViewModel, IVehiclesLoadedHandler
    {
        private List<Line> AllLines { get; set; }
        public ObservableCollection<GroupedObservableCollection<string, Line>> LinesGrouped { get; set; }

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

            //TODO: load lines off the main thread with a task or observable 
            AllLines = LinesLoader.Load();
            GroupLines(AllLines);

            this.WhenActivated(disposables =>
            {
                this.WhenAnyValue(vm => vm.SelectedLine)
                    .Where(line => line != null)
                    .Do(_ =>
                    {
                        if (!CrossConnectivity.Current.IsConnected)
                        {
                            //TODO: show a dialog or smth
                        }
                    })
                    .SelectMany(line => this.vehiclesSevice.FetchVehicles(line.Type, line.Symbol)
                        .Select(vehicles => new VehiclesLoadedEventArgs(vehicles, new List<Line> { line }))
                    )
                    .SubscribeOn(this.taskPoolScheduler)
                    .ObserveOn(this.mainThreadScheduler)
                    .Subscribe(
                        onNext: args =>
                        {
                            if (args.Vehicles == null || !args.Vehicles.Any())
                            {
                                //TODO: show a dialog or smth
                            }
                            else
                            {
                                OnVehiclesLoaded?.Invoke(this, args);
                                NavigateBack().Subscribe().DisposeWith(disposables);
                            }
                        },
                        onError: error =>
                        {
                            //TODO: show a dialog or smth
                        })
                    .DisposeWith(disposables);

                this.WhenAnyValue(vm => vm.SearchInput)
                    .Where(input => !string.IsNullOrEmpty(input))
                    .DistinctUntilChanged()
                    .Subscribe(input =>
                    {
                        FilterLines(input);
                    })
                    .DisposeWith(disposables);
            });
        }

        public Line FindBy(string symbol) => AllLines.Where(l => l.Symbol == symbol).FirstOrDefault();

        //TODO: fix filtering with searchbar
        private void FilterLines(string filter)
        {
            if (filter == null)
                return;
            else if (!filter.Any())
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
    }
}
