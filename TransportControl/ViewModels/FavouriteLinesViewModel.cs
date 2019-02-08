using ReactiveUI;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reactive.Concurrency;
using System.Reactive.Linq;
using System.Reactive.Threading.Tasks;
using TransportControl.Models;
using TransportControl.Services;

namespace TransportControl.ViewModels
{
    public class FavouriteLinesViewModel : BaseLinesViewModel
    {
        public bool NoLinesLabelVisible => LinesGrouped == null || !LinesGrouped.Any();

        public FavouriteLinesViewModel(
            IScheduler mainThreadScheduler = null,
            IScheduler taskPoolScheduler = null,
            IVehiclesService vehiclesSevice = null,
            IScreen hostScreen = null
        ) : base(mainThreadScheduler, taskPoolScheduler, vehiclesSevice, hostScreen)
        {
        }

        protected override IObservable<List<Line>> LoadLines() => vehiclesSevice.GetFavouriteLines()
            .ToObservable()
            .Select(lines => lines.ToList());
    }
}
