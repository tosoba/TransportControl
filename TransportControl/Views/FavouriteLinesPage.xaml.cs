using ReactiveUI;
using System.Reactive.Disposables;
using TransportControl.ViewModels;
using Xamarin.Forms.Xaml;

namespace TransportControl.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class FavouriteLinesPage : BaseContentPage<FavouriteLinesViewModel>
    {
        public FavouriteLinesPage()
        {
            InitializeComponent();

            this.WhenActivated(disposables =>
            {
                Content.BindingContext = ViewModel;

                this.Bind(ViewModel, vm => vm.SelectedLine, view => view.LinesContent.ContentLinesListView.SelectedItem)
                    .DisposeWith(disposables);

                this.Bind(ViewModel, vm => vm.SearchInput, view => view.LinesContent.ContentLineSearchBar.Text)
                    .DisposeWith(disposables);

                this.Bind(ViewModel, vm => vm.NoLinesLabelVisible, view => view.NoLinesLabel.IsVisible)
                    .DisposeWith(disposables);  
            });
        }
    }
}