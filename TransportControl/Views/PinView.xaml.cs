using Xamarin.Forms;

namespace TransportControl.Views
{
    public partial class PinView : StackLayout
    {
        public PinView(string display, string source)
        {
            InitializeComponent();

            Display = display;
            Source = source;

            BindingContext = this;
        }

        public string Display { private set; get; }

        public string Source { private set; get; }
    }
}

