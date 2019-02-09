using System;
using ReactiveUI;
using TransportControl.Services;
using System.Reactive.Concurrency;
using System.Collections.Generic;
using TransportControl.Models;
using Xamarin.Forms;
using Acr.UserDialogs;

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
            FavouritesActionText = "Add to favourites";
            FavouritesActionCommand = new Command<Line>(async line =>
            {
                if (await this.vehiclesSevice.AddToFavourites(line))
                    UserDialogs.Instance.Toast($"{line.Symbol} added to favourites.");
                else
                    UserDialogs.Instance.Toast($"{line.Symbol} already added to favourites.");
            });
        }

        protected override IObservable<List<Line>> LinesObservable => vehiclesSevice.LoadLines();
    }
}
