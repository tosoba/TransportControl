using TransportControl.ViewModels;
using Xamarin.Forms.Xaml;

namespace TransportControl.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class ChooseLocationPage : BaseContentPage<ChooseLocationViewModel>
    {
		public ChooseLocationPage ()
		{
			InitializeComponent ();
        }
	}
}