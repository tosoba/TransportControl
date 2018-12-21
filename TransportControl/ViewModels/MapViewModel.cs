using Plugin.Connectivity;
using Plugin.Connectivity.Abstractions;
using System.ComponentModel;
using System.Windows.Input;
using Xamarin.Forms;

namespace TransportControl.ViewModels
{
    public class MapViewModel : INotifyPropertyChanged
    {
        public INavigation Navigation { get; private set; }

        public ICommand ClearMap { get; }
        public ICommand GoToLines { get; }
        public ICommand GoToRadius { get; }

        private bool isConnected = false;
        public bool IsConnected
        {
            get { return isConnected; }
            private set
            {
                if (isConnected != value)
                {
                    isConnected = value;
                    OnPropertyChanged(nameof(IsConnected));
                }
            }
        }

        public MapViewModel(INavigation navigation)
        {
            Navigation = navigation;

            var linePage = new LinePage();
            linePage.OnVehiclesLoaded += OnVehiclesLoadedListener.OnVehiclesLoaded;

            var chooseRadiusPage = new ChooseRadiusPage();
            chooseRadiusPage.OnVehiclesLoaded += OnVehiclesLoadedListener.OnVehiclesLoaded;

            ClearMap = new Command(() =>
            {
                VehicleUpdater.Instance.IsRunning = false;
            });

            GoToLines = new Command(async () =>
            {
                await Navigation.PushAsync(linePage);
            });

            GoToRadius = new Command(async () =>
            {
                await Navigation.PushAsync(chooseRadiusPage);
            });

            IsConnected = CrossConnectivity.Current.IsConnected;
            CrossConnectivity.Current.ConnectivityChanged += OnConnectivityChanged;
        }

        public event PropertyChangedEventHandler PropertyChanged;

        protected void OnPropertyChanged(string name)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }

        private void OnConnectivityChanged(object sender, ConnectivityChangedEventArgs e)
        {
            IsConnected = e.IsConnected;
        }
    }
}
