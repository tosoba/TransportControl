using ReactiveUI;
using System;
using System.Linq;
using System.Reactive.Disposables;
using TransportControl.ViewModels;
using TransportControl.Views;
using Xamarin.Forms;

namespace TransportControl
{
    public partial class LinePage : BaseContentPage<LinesViewModel>
    {
        public LinePage()
        {
            InitializeComponent();

            this.WhenActivated(disposables =>
            {
                //TODO: see if this can be bound like that later
                //this.OneWayBind(ViewModel, vm => vm.LinesGrouped, x => x.LinesListView.ItemsSource).DisposeWith(disposables);

                this.Bind(ViewModel, vm => vm.SelectedLine, view => view.LinesListView.SelectedItem)
                    .DisposeWith(disposables);

                this.Bind(ViewModel, vm => vm.SearchInput, view => view.LineSearchBar.Text);
            });
        }

        private void OnLineNumberBtnClicked(object sender, EventArgs e)
        {
            switch ((sender as Button).Text)
            {
                case "1":
                    LinesListView.ScrollTo(ViewModel.LinesGrouped
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
            {
                LinesListView.ScrollTo(target, ScrollToPosition.Start, false);
            }
        }
    }
}
