using TransportControl.Utils;
using Xamarin.Forms;
using Xamarin.Forms.GoogleMaps;
using Xamarin.Forms.Xaml;

[assembly: XamlCompilation(XamlCompilationOptions.Compile)]
namespace TransportControl
{
    public partial class App : Application
    {
        public static readonly Position warsawCenterPosition = new Position(52.237049, 21.017532);

        public App()
        {
            InitializeComponent();
            ThemeManager.LoadTheme();
            var bootstrapper = new AppBootstrapper();
            MainPage = bootstrapper.CreateMainPage();
        }
    }
}

