using Xamarin.Forms;

namespace TransportControl
{
    public partial class BindingPinView : StackLayout
    {

        public BindingPinView(string display, string source)
        {
            InitializeComponent();

            Display = display;
            Source = source;

            BindingContext = this;
        }

        public string Display
        {
            private set;
            get;
        }

        public string Source
        {
            private set;
            get;
        }
    }
}

