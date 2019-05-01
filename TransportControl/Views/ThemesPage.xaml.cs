using ReactiveUI;
using System.Reactive.Disposables;
using TransportControl.ViewModels;
using Xamarin.Forms.Xaml;

namespace TransportControl.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class ThemesPage : BaseContentPage<ThemesViewModel>
    {
        public ThemesPage()
        {
            InitializeComponent();

            this.WhenActivated(disposables =>
            {
                Content.BindingContext = ViewModel;

                this.Bind(ViewModel, vm => vm.SelectedTheme, view => view.ThemesListView.SelectedItem)
                    .DisposeWith(disposables);
            });
        }
    }
}