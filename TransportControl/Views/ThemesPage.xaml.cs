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
        }
    }
}