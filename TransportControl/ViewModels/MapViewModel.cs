using System.Windows.Input;
using Xamarin.Forms;

namespace TransportControl.ViewModels
{
    public class MapViewModel
    {
        public INavigation Navigation { get; private set; }

        public ICommand ClearMap { get; }
        public ICommand GoToLines { get; }
        public ICommand GoToRadius { get; }

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
        }
    }
}
