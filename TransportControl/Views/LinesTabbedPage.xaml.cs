using ReactiveUI;
using ReactiveUI.XamForms;
using System.Reactive.Disposables;
using TransportControl.ViewModels;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace TransportControl.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class LinesTabbedPage : ReactiveTabbedPage<LinesTabbedViewModel>
    {
        public LinesTabbedPage()
        {
            InitializeComponent();

            if (Device.RuntimePlatform == Device.iOS)
            {
                AllLinesPage.Icon = "list.png";
                FavouritesLinesPage.Icon = "heart.png";
            }

            this.WhenActivated(disposables =>
            {
                Title = "Transport Control";

                this.OneWayBind(ViewModel, vm => vm.FavouriteLinesViewModel, view => view.FavouritesLinesPage.ViewModel)
                    .DisposeWith(disposables);
                this.OneWayBind(ViewModel, vm => vm.AllLinesViewModel, view => view.AllLinesPage.ViewModel)
                    .DisposeWith(disposables);
            });
        }
    }
}