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
					var mdp = (Application.Current.MainPage as MasterDetailPage);
					var navPage = mdp.Detail as Xamarin.Forms.NavigationPage;
                    mdp.IsPresented = false; // Hide the Master page

                    await Task.Delay(255);

                    switch (value)
					{
						case "1":
                            var linePage = new LinePage();
                            linePage.OnVehiclesLoaded += OnVehiclesLoadedListener.OnVehiclesLoaded;
							await navPage.PushAsync(linePage);
							break;
						case "2":
                            var chooseRadiusPage = new ChooseRadiusPage();
                            chooseRadiusPage.OnVehiclesLoaded += OnVehiclesLoadedListener.OnVehiclesLoaded;
                            await navPage.PushAsync(chooseRadiusPage);
                            break;
					}
				});
			}
		}
	}
}
