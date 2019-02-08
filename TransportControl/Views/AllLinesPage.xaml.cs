using ReactiveUI;
using System.Reactive.Disposables;
using TransportControl.ViewModels;

namespace TransportControl.Views
{
    public partial class AllLinesPage : BaseContentPage<AllLinesViewModel>
    {
        public AllLinesPage()
        {
            InitializeComponent();

            this.WhenActivated(disposables =>
            {
                Content.BindingContext = ViewModel;

                this.Bind(ViewModel, vm => vm.SelectedLine, view => view.LinesContent.ContentLinesListView.SelectedItem)
                    .DisposeWith(disposables);

                this.Bind(ViewModel, vm => vm.SearchInput, view => view.LinesContent.ContentLineSearchBar.Text)
                    .DisposeWith(disposables);
            });
        }
    }
}
