using System;
using System.Linq;
using TransportControl.ViewModels;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace TransportControl.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class LinesPageContent : ContentView
    {
        public ListView ContentLinesListView => LinesListView;

        public SearchBar ContentLineSearchBar => LineSearchBar;

        private BaseLinesViewModel ViewModel => BindingContext as BaseLinesViewModel;

        public LinesPageContent()
        {
            InitializeComponent();
        }

        private void OnLineNumberBtnClicked(object sender, EventArgs e)
        {
            switch ((sender as Button).Text)
            {
                case "1":
                    ContentLinesListView.ScrollTo(ViewModel.LinesGrouped
                        .FirstOrDefault(group => group.Any(line => line.Symbol.Length < 3))
                        ?.FirstOrDefault(), ScrollToPosition.Start, false);
                    break;
                case "100":
                    ScrollToFirstLineNumberStartingWith(text: "1"); break;
                case "200":
                    ScrollToFirstLineNumberStartingWith(text: "2"); break;
                case "300":
                    ScrollToFirstLineNumberStartingWith(text: "3"); break;
                case "400":
                    ScrollToFirstLineNumberStartingWith(text: "4"); break;
                case "500":
                    ScrollToFirstLineNumberStartingWith(text: "5"); break;
                case "600":
                    ScrollToFirstLineNumberStartingWith(text: "6"); break;
                case "700":
                    ScrollToFirstLineNumberStartingWith(text: "7"); break;
                case "E":
                    ScrollToFirstLineNumberStartingWith(text: "E"); break;
                default: break;
            }
        }

        private void ScrollToFirstLineNumberStartingWith(string text)
        {
            var target = ViewModel.LinesGrouped
                .FirstOrDefault(group => group.Any(line => line.Symbol.StartsWith(text) && line.Symbol.Length > 2))
                ?.FirstOrDefault();

            if (target != null)
                ContentLinesListView.ScrollTo(target, ScrollToPosition.Start, false);
        }
    }
}