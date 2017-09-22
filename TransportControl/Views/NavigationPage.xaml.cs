using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;
using TransportControl.ViewModels;

namespace TransportControl
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class NavigationPage : ContentPage
    {
        public NavigationPage()
        {
            InitializeComponent();
            BindingContext = new NavigationViewModel();
        }
    }
}