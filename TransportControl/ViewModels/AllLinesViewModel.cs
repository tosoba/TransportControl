using System;
using ReactiveUI;
using TransportControl.Services;
using System.Reactive.Concurrency;
using System.Collections.Generic;
using TransportControl.Models;

namespace TransportControl.ViewModels
{
    public class AllLinesViewModel : BaseLinesViewModel
    {
        public AllLinesViewModel(
            IScheduler mainThreadScheduler = null,
            IScheduler taskPoolScheduler = null,
            IVehiclesService vehiclesSevice = null,
            IScreen hostScreen = null
        ) : base(mainThreadScheduler, taskPoolScheduler, vehiclesSevice, hostScreen)
        {
        }

        protected override IObservable<List<Line>> LoadLines() => vehiclesSevice.LoadLines();
    }
}
