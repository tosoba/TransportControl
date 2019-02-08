using TransportControl.ViewModels;
using Xamarin.Forms.Xaml;
using TransportControl.Views;
using ReactiveUI;
using System.Reactive.Disposables;

namespace TransportControl
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
            });
        }
    }
}