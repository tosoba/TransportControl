using TransportControl.ViewModels;
using TransportControl.Views;
using Xamarin.Forms.Xaml;

namespace TransportControl
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class FavouriteLinesPage : BaseContentPage<FavouriteLinesViewModel>
    {
        public FavouriteLinesPage()
        {
            InitializeComponent();
        }
    }
}