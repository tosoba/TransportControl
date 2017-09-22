using System.Threading.Tasks;
using System.Windows.Input;
using Xamarin.Forms;

namespace TransportControl.ViewModels
{
	public class NavigationViewModel
	{
		public ICommand NavigationCommand
		{
			get
			{
				return new Command(async (value) =>
				{
					// COMMENT: This is just quick demo code. Please don't put this in a production app.
					var mdp = (Application.Current.MainPage as MasterDetailPage);
					var navPage = mdp.Detail as Xamarin.Forms.NavigationPage;
                    // Hide the Master page
                    mdp.IsPresented = false;

                    await Task.Delay(255);

                    switch (value)
					{
						case "1":
							//await navPage.PushAsync(new BasicMapPage());
							break;
						case "2":
                            //await navPage.PushAsync(new BasicMapPage());
							break;
					}
				});
			}
		}
	}
}
