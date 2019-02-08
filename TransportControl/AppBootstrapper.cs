using ReactiveUI;
using ReactiveUI.XamForms;
using Splat;
using System;
using TransportControl.Services;
using TransportControl.ViewModels;
using Xamarin.Forms;

namespace TransportControl
{
    public class AppBootstrapper : ReactiveObject, IScreen
    {
        public RoutingState Router { get; protected set; }

        public AppBootstrapper()
        {
            Router = new RoutingState();

            Locator.CurrentMutable.RegisterConstant(this, typeof(IScreen));

            Locator.CurrentMutable.Register(() => new MapPage(), typeof(IViewFor<MapViewModel>));
            Locator.CurrentMutable.Register(() => new LinePage(), typeof(IViewFor<LinesViewModel>));
            Locator.CurrentMutable.Register(() => new ChooseRadiusPage(), typeof(IViewFor<RadiusViewModel>));
            Locator.CurrentMutable.Register(() => new FavouriteLinesPage(), typeof(IViewFor<FavouriteLinesViewModel>));
            Locator.CurrentMutable.Register(() => new LinesTabbedPage(), typeof(IViewFor<LinesTabbedViewModel>));

            Locator.CurrentMutable.Register(() => new VehiclesService(), typeof(IVehiclesService));

            Router.NavigateAndReset
                .Execute(new MapViewModel())
                .Subscribe();
        }

        // NB: This returns the opening page that the platform-specific
        // boilerplate code will look for. It will know to find us because
        // we've registered our AppBootstrappScreen.
        public Page CreateMainPage() => new RoutedViewHost();
    }
}
