using Android.App;
using Android.Widget;
using TransportControl.Droid;

[assembly: Xamarin.Forms.Dependency(typeof(MessageAndroid))]
namespace TransportControl.Droid
{
    class MessageAndroid : IMessage
    {
        public void LongAlert(string message) => Toast.MakeText(Application.Context, message, ToastLength.Long).Show();
        
        public void ShortAlert(string message) => Toast.MakeText(Application.Context, message, ToastLength.Short).Show();
    }
}