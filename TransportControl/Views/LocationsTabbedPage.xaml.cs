using ReactiveUI;
using ReactiveUI.XamForms;
using System.Reactive.Disposables;
using TransportControl.ViewModels;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace TransportControl.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class LocationsTabbedPage : ReactiveTabbedPage<LocationsTabbedViewModel>
    {
		public LocationsTabbedPage()
		{
			InitializeComponent();

            if (Device.RuntimePlatform == Device.iOS)
            {
                ChooseLocationPage.Icon = "location.png";
                FavouriteLocationsPage.Icon = "heart.png";
            }

            this.WhenActivated(disposables =>
            {
                Title = "Transport Control";

                this.OneWayBind(ViewModel, vm => vm.FavouriteLocationsViewModel, view => view.FavouriteLocationsPage.ViewModel)
                    .DisposeWith(disposables);
                this.OneWayBind(ViewModel, vm => vm.ChooseLocationViewModel, view => view.ChooseLocationPage.ViewModel)
                    .DisposeWith(disposables);

                this.BindCommand(ViewModel, vm => vm.GoToRadius, view => view.NearbyMenuItem);
            });
        }
	}
}