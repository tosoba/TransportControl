using Acr.UserDialogs;
using ReactiveUI;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Reactive.Concurrency;
using System.Reactive.Disposables;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using TransportControl.List;
using TransportControl.Models;
using TransportControl.Services;
using Xamarin.Forms;

namespace TransportControl.ViewModels
{
    public class FavouriteLinesViewModel : BaseLinesViewModel
    {
        public bool NoLinesLabelVisible => LinesGrouped == null || !LinesGrouped.Any();

        public override ObservableCollection<GroupedObservableCollection<string, Line>> LinesGrouped
        {
            get => base.LinesGrouped;
            set
            {
                base.LinesGrouped = value;
                this.RaisePropertyChanged("NoLinesLabelVisible");
            }
        }

        public FavouriteLinesViewModel(
            IScheduler mainThreadScheduler = null,
            IScheduler taskPoolScheduler = null,
            IVehiclesService vehiclesSevice = null,
            IScreen hostScreen = null
        ) : base(mainThreadScheduler, taskPoolScheduler, vehiclesSevice, hostScreen)
        {
            this.WhenActivated((CompositeDisposable disposables) =>
            {
                FavouritesActionCommand = new Command<Line>(async line =>
                {
                    await this.vehiclesSevice.RemoveFromFavourites(line);
                    LoadLines(disposables);
                    UserDialogs.Instance.Toast($"{line.Symbol} removed from favourites.");
                });
            });
            FavouritesActionText = "Remove from favourites";
        }

        protected override IObservable<List<Line>> LinesObservable => vehiclesSevice.GetFavouriteLines()
            .ToObservable()
            .Select(lines => lines.ToList());
    }
}
