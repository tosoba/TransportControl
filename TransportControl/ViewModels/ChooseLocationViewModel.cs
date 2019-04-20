using Acr.UserDialogs;
using ReactiveUI;
using Splat;
using System;
using System.Reactive.Linq;
using System.Windows.Input;
using TransportControl.Db;
using TransportControl.Events;
using TransportControl.Models;

namespace TransportControl.ViewModels
{
    public class ChooseLocationViewModel : BaseVehicleLoadingViewModel, IVehiclesLoadedHandler
    {
        public ICommand AddToFavourites { get; }
        public ICommand GoToRadius { get; }

        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

        public Location ChosenLocation { get; set; }

        private IAppDatabase db;

        public ChooseLocationViewModel(IAppDatabase db = null)
        {
            this.db = db ?? Locator.Current.GetService<IAppDatabase>();

            GoToRadius = ReactiveCommand.CreateFromObservable(() =>
            {
                var vm = new ChooseRadiusViewModel(ChosenLocation);
                vm.OnVehiclesLoaded += OnVehiclesLoaded;
                return NavigateTo(vm);
            });

            AddToFavourites = ReactiveCommand.CreateFromObservable(() =>
            {
                return Observable.FromAsync(async () => await UserDialogs.Instance.PromptAsync(new PromptConfig
                {
                    Placeholder = "Location name",
                    InputType = InputType.Name,
                    OkText = "Ok",
                    Title = "Save location",
                }))
                .Do(promptResult =>
                {
                    if (string.IsNullOrWhiteSpace(promptResult.Text))
                    {
                        UserDialogs.Instance.Toast("Invalid name.");
                    }
                    else if (!promptResult.Ok || ChosenLocation == null)
                    {
                        UserDialogs.Instance.Toast("Error occurred - try again.");
                    }
                })
                .Where(promptResult =>
                {
                    return promptResult.Ok && !string.IsNullOrWhiteSpace(promptResult.Text) && ChosenLocation != null;
                })
                .SubscribeOn(RxApp.MainThreadScheduler)
                .ObserveOn(RxApp.TaskpoolScheduler)
                .SelectMany(promptResult =>
                {
                    ChosenLocation.Name = promptResult.Text;
                    return Observable.FromAsync(() => this.db.InsertLocation(ChosenLocation));
                })
                .ObserveOn(RxApp.MainThreadScheduler)
                .Do(wasAdded =>
                {
                    if (wasAdded) UserDialogs.Instance.Toast($"{ChosenLocation.Name} added to favourites.");
                    else UserDialogs.Instance.Toast($"{ChosenLocation.Name} already added to favourites.");
                });
            });
        }
    }
}
