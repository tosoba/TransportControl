using ReactiveUI;
using System.Reactive.Disposables;
using TransportControl.ViewModels;
using Xamarin.Forms.Xaml;

namespace TransportControl.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class FavouriteLocationsPage : BaseContentPage<FavouriteLocationsViewModel>
    {
        public FavouriteLocationsPage()
        {
            InitializeComponent();

            this.WhenActivated(disposables =>
            {
                this.Bind(ViewModel, vm => vm.SelectedLocation, view => view.LocationsListView.SelectedItem)
                   .DisposeWith(disposables);

                this.Bind(ViewModel, vm => vm.NoLocationsLabelVisible, view => view.NoLocationsLabel.IsVisible)
                   .DisposeWith(disposables);
            });
        }
    }
}