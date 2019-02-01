using ReactiveUI;
using System;
using System.Collections.ObjectModel;
using System.Reactive.Disposables;
using System.Reactive.Linq;
using TransportControl.Events;
using TransportControl.Models;

namespace TransportControl.ViewModels
{
    public class RadiusViewModel : BaseViewModel, IVehiclesLoadedHandler
    {
        public ObservableCollection<Distance> Distances { get; set; } = new ObservableCollection<Distance>
        {
            new Distance(100),
            new Distance(250),
            new Distance(500),
            new Distance(1000),
            new Distance(2000),
            new Distance(5000),
            new Distance(10000)
        };

        private Distance selectedDistance;
        public Distance SelectedDistance
        {
            set { this.RaiseAndSetIfChanged(ref selectedDistance, value); }
            get { return selectedDistance; }
        }

        public event EventHandler<VehiclesLoadedEventArgs> OnVehiclesLoaded;

        public RadiusViewModel(IScreen hostScreen = null) : base(hostScreen)
        {
            this.WhenActivated(disposables =>
            {
                //TODO: try to make this work somehow with both checking permissions and internet connection
                this.WhenAnyValue(vm => vm.SelectedDistance)
                    .Where(d => d != null)
                    .Subscribe()
                    .DisposeWith(disposables);
            });
        }
    }
}
