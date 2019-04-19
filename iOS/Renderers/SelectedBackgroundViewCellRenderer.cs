using ListViewDemo.CustomControls;
using UIKit;
using Xamarin.Forms;
using Xamarin.Forms.Platform.iOS;
using ListViewDemo.iOS.CustomControls;
using TransportControl.Views;

[assembly: ExportRenderer(typeof(SelectedBackgroundViewCell), typeof(SelectedBackgroundViewCellRenderer))]
namespace ListViewDemo.iOS.CustomControls
{
    public class SelectedBackgroundViewCellRenderer : ViewCellRenderer
    {
        public override UITableViewCell GetCell(Cell item, UITableViewCell reusableCell, UITableView tv)
        {
            var cell = base.GetCell(item, reusableCell, tv);
            var view = item as CustomViewCell;
            SelectedBackgroundView = new UIView
            {
                BackgroundColor = view.SelectedItemBackgroundColor.ToUIColor(),
            };
            return cell;
        }
    }
}