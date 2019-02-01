using ReactiveUI;
using Splat;
using System;
using System.Reactive;

namespace TransportControl.ViewModels
{
    public class BaseViewModel : ReactiveObject, IRoutableViewModel, ISupportsActivation
    {
        public string UrlPathSegment { get; protected set; }

        public IScreen HostScreen { get; protected set; }

        protected readonly ViewModelActivator viewModelActivator = new ViewModelActivator();
        public ViewModelActivator Activator
        {
            get { return viewModelActivator; }
        }

        public BaseViewModel(IScreen hostScreen = null)
        {
            HostScreen = hostScreen ?? Locator.Current.GetService<IScreen>();
        }

        protected IObservable<IRoutableViewModel> NavigateTo(IRoutableViewModel viewModel) => HostScreen.Router.Navigate.Execute(viewModel);

        protected IObservable<Unit> NavigateBack() => HostScreen.Router.NavigateBack.Execute();
    }
}
