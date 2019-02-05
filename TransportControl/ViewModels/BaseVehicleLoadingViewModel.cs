using ReactiveUI;
using System;
using System.Linq;
using Splat;
using System.Reactive.Concurrency;
using System.Reactive.Disposables;
using System.Reactive.Linq;
using Acr.UserDialogs;
using TransportControl.Services;

namespace TransportControl.ViewModels
{
    public class BaseVehicleLoadingViewModel : BaseViewModel
    {
        private bool loadingVehiclesInProgress = false;
        protected bool LoadingVehiclesInProgress
        {
            get { return loadingVehiclesInProgress; }
            set { this.RaiseAndSetIfChanged(ref loadingVehiclesInProgress, value); }
        }

        protected IVehiclesService vehiclesSevice;

        protected IScheduler mainThreadScheduler;
        protected IScheduler taskPoolScheduler;

        public BaseVehicleLoadingViewModel(IScheduler mainThreadScheduler = null,
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
                this.WhenAnyValue(vm => vm.LoadingVehiclesInProgress)
                   .Skip(1)
                   .DistinctUntilChanged()
                   .SubscribeOn(this.mainThreadScheduler)
                   .ObserveOn(this.mainThreadScheduler)
                   .Subscribe(isLoading =>
                   {
                       if (isLoading) UserDialogs.Instance.ShowLoading("Loading vehicles' data...");
                       else UserDialogs.Instance.HideLoading();
                   })
                   .DisposeWith(disposables);
            });
        }

        protected void OnVehiclesDataLoadingFailure(string message = null)
        {
            UserDialogs.Instance.Toast(message ?? "Unable to load vehicles' data.");
        }
    }
}
