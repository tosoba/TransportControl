using ReactiveUI;
using System;
using System.Collections.ObjectModel;
using System.Reactive.Concurrency;
using TransportControl.List;
using TransportControl.Models;
using TransportControl.Services;
using System.Reactive.Disposables;
using System.Collections.Generic;
using System.Reactive.Linq;
using System.Linq;
using MoreLinq;
using Plugin.Connectivity;
using Xamarin.Forms;
using Acr.UserDialogs;
using TransportControl.Events;

namespace TransportControl.ViewModels
{
    public abstract class BaseLinesViewModel : BaseVehicleLoadingViewModel, IVehiclesLoadedHandler
    {
        protected List<Line> AllLines { get; set; }

        private ObservableCollection<GroupedObservableCollection<string, Line>> linesGrouped;
        public virtual ObservableCollection<GroupedObservableCollection<string, Line>> LinesGrouped
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

        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

        private string favouritesActionText;
        public string FavouritesActionText
        {
            get => favouritesActionText;
            protected set => this.RaiseAndSetIfChanged(ref favouritesActionText, value);
        }

        public Command<Line> FavouritesActionCommand { get; protected set; }

        protected BaseLinesViewModel(
            IScheduler mainThreadScheduler = null,
            IScheduler taskPoolScheduler = null,
            IVehiclesService vehiclesSevice = null,
            IScreen hostScreen = null
        ) : base(mainThreadScheduler, taskPoolScheduler, vehiclesSevice, hostScreen)
        {
            this.WhenActivated(disposables =>
            {
                SelectedLine = null;

                LoadLines(disposables);

                this.WhenAnyValue(vm => vm.SearchInput)
                    .Where(input => input != null)
                    .DistinctUntilChanged()
                    .Subscribe(FilterAndGroupLines)
                    .DisposeWith(disposables);

                SetupLineSelected(disposables);
            });
        }

        protected abstract IObservable<List<Line>> LinesObservable { get; }

        protected void LoadLines(CompositeDisposable disposables)
        {
            LinesObservable
               .Select(lines =>
               {
                   return new Tuple<List<Line>, ObservableCollection<GroupedObservableCollection<string, Line>>>(
                       lines, GroupLines(lines)
                   );
               })
               .SubscribeOn(taskPoolScheduler)
               .ObserveOn(mainThreadScheduler)
               .Subscribe(tuple =>
               {
                   AllLines = tuple.Item1;
                   LinesGrouped = tuple.Item2;
               })
               .DisposeWith(disposables);
        }

        protected void FilterAndGroupLines(string filter)
        {
            if (!filter.Trim().Any())
                GroupLines(AllLines);
            else
            {
                var filteredLines = AllLines.Where(l => l.Symbol.ToLower().Contains(filter.ToLower())).ToList();
                GroupLines(filteredLines);
            }
        }

        protected ObservableCollection<GroupedObservableCollection<string, Line>> GroupLines(List<Line> lines)
        {
            var groups = lines.GroupBy(l => l.GroupSymbol)
                 .Select(lg => new GroupedObservableCollection<string, Line>(lg.Key, lg));
            if (!groups.Any())
                return new ObservableCollection<GroupedObservableCollection<string, Line>>();
            else
            {
                var dividedGroups = groups.Partition(lg => lg.Key.All(char.IsDigit)).ToTuple();
                var numberOnlyLines = dividedGroups.Item1
                    .Select(lg => new GroupedObservableCollection<string, Line>(lg.Key, lg.OrderBy(l => int.Parse(l.Symbol))));
                var linesContainingLetters = dividedGroups.Item2
                    .Select(lg => new GroupedObservableCollection<string, Line>(lg.Key, lg.OrderBy(l => l.Symbol)));
                return new ObservableCollection<GroupedObservableCollection<string, Line>>(numberOnlyLines.Concat(linesContainingLetters));
            }
        }

        private void SetupLineSelected(CompositeDisposable disposables)
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
                .Do(_ => { LoadingVehiclesInProgress = true; })
                .SelectMany(line => vehiclesSevice.FetchVehicles(line.Type, line.Symbol)
                    .Select(vehicles => new VehiclesLoadedEventArgs(vehicles, new List<Line> { line }))
                )
                .OnErrorResumeNext(Observable.Return(VehiclesLoadedEventArgs.Error))
                .SubscribeOn(taskPoolScheduler)
                .ObserveOn(mainThreadScheduler)
                .Do(_ => { LoadingVehiclesInProgress = false; })
                .Subscribe(
                    onNext: args =>
                    {
                        SelectedLine = null;
                        if (args.ErrorOccurred)
                        {
                            OnVehiclesDataLoadingFailure();
                        }
                        else if (args.Vehicles == null || !args.Vehicles.Any())
                        {
                            OnVehiclesDataLoadingFailure("No vehicles found.");
                        }
                        else
                        {
                            OnVehiclesLoaded?.Invoke(this, args);
                            NavigateBack().Subscribe().DisposeWith(disposables);
                        }
                    },
                    onCompleted: () =>
                    {
                        SelectedLine = null;
                        LoadingVehiclesInProgress = false;
                        SetupLineSelected(disposables);
                    })
                .DisposeWith(disposables);
        }
    }
}
