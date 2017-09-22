using Acr.UserDialogs;

namespace TransportControl
{
    public static class Dialogs
    {
        public static void ShowAlertDialog(string title, string message)
        {
            UserDialogs.Instance.Alert(new AlertConfig()
            {
                Title = title,
                Message = message
            });
        }
    }
}
