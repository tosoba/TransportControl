using Xamarin.Forms;
using Xamarin.Forms.Xaml;

[assembly: XamlCompilation(XamlCompilationOptions.Compile)]
namespace TransportControl
{
    public partial class App : Application
    {
        public App()
        {
            InitializeComponent();
            
            var bootstrapper = new AppBootstrapper();
            MainPage = bootstrapper.CreateMainPage();
        }
    }
}

