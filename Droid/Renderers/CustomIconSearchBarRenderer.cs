using Android.Content;
using Android.Support.V4.Content;
using Android.Widget;
using TransportControl.Droid.Renderers;
using TransportControl.Views;
using Xamarin.Forms;
using Xamarin.Forms.Platform.Android;

[assembly: ExportRenderer(typeof(CustomIconSearchBar), typeof(CustomIconSearchBarRenderer))]
namespace TransportControl.Droid.Renderers
{
    public class CustomIconSearchBarRenderer : SearchBarRenderer
    {
        public CustomIconSearchBarRenderer(Context context) : base(context)
        {
        }

        protected override void OnElementChanged(ElementChangedEventArgs<SearchBar> e)
        {
            base.OnElementChanged(e);
            int searchPlateId = Control.Context.Resources.GetIdentifier("android:id/search_mag_icon", null, null);
            ImageView searchButton = Control.FindViewById<ImageView>(searchPlateId);
            searchButton.SetImageDrawable(ContextCompat.GetDrawable(Context, Resource.Drawable.search_icon));
        }
    }
}