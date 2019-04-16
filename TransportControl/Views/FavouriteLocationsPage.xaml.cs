using TransportControl.ViewModels;
using Xamarin.Forms.Xaml;

namespace TransportControl.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class FavouriteLocationsPage : BaseContentPage<FavouriteLocationsViewModel>
    {
		public FavouriteLocationsPage ()
		{
			InitializeComponent ();
		}
	}
}