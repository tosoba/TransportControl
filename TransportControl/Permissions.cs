using Plugin.Permissions;
using Plugin.Permissions.Abstractions;
using System;
using System.Threading.Tasks;

namespace TransportControl
{
    public static class Permissions
    {
        public static async Task Check()
        {
            try
            {
                var status = await CrossPermissions.Current.CheckPermissionStatusAsync(Permission.Location);
                if (status != PermissionStatus.Granted)
                {
                    if (await CrossPermissions.Current.ShouldShowRequestPermissionRationaleAsync(Permission.Location))
                    {
                        Dialogs.ShowAlertDialog("Location", "Need permissions to access device location.");
                    }

                    var results = await CrossPermissions.Current.RequestPermissionsAsync(new[] { Permission.Location });
                    status = results[Permission.Location];
                }
            }
            catch (Exception ex)
            {
                Dialogs.ShowAlertDialog("Location", $"Exception thrown: {ex.Message}");
            }
        }
    }
}
