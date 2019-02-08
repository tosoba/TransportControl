using ReactiveUI;
using ReactiveUI.XamForms;
using System.Reactive.Disposables;
using TransportControl.ViewModels;
using Xamarin.Forms.Xaml;

namespace TransportControl
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class LinesTabbedPage : ReactiveTabbedPage<LinesTabbedViewModel>
    {
        public LinesTabbedPage()
        {
            InitializeComponent();

            this.WhenActivated(disposables =>
            {
                this.OneWayBind(ViewModel, vm => vm.FavouriteLinesViewModel, view => view.FavouritesLinesPage.ViewModel)
                    .DisposeWith(disposables);
                this.OneWayBind(ViewModel, vm => vm.LinesViewModel, view => view.LinesPage.ViewModel)
                    .DisposeWith(disposables);
            });
        }
    }
}