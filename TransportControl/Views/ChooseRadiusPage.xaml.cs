using TransportControl.ViewModels;
using Xamarin.Forms.Xaml;
using ReactiveUI;
using System.Reactive.Disposables;

namespace TransportControl.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class ChooseRadiusPage : BaseContentPage<ChooseRadiusViewModel>
    {
        public ChooseRadiusPage()
        {
            InitializeComponent();

            this.WhenActivated(disposables =>
            {
                Title = "Search radius";

                this.Bind(ViewModel, vm => vm.SelectedDistance, view => view.DistancesListView.SelectedItem)
                   .DisposeWith(disposables);

                this.Bind(ViewModel, vm => vm.FavouritesOnly, view => view.FavouritesOnlySwitch.IsToggled)
                   .DisposeWith(disposables);

                this.Bind(ViewModel, vm => vm.AnyFavouritesAdded, view => view.RadiusListViewHeader.IsVisible)
                   .DisposeWith(disposables);
            });
        }
    }
}