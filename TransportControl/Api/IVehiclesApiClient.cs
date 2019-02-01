using Refit;
using System;
using TransportControl.Models;

namespace TransportControl.Api
{
    [Headers("Content-Type: application/json")]
    public interface IVehiclesApiClient
    {
        [Get("/busestrams_get/?resource_id={resourceId}&apikey={apiKey}&type={type}")]
        IObservable<VehiclesResponse> FetchAllVehiclesOfType(
            int type,
            string apiKey = Keys.WARSAW_API_KEY,
            string resourceId = "f2e5503e-927d-4ad3-9500-4ab9e55deb59"
        );

        [Get("/busestrams_get/?resource_id={resourceId}&apikey={apiKey}&type={type}&line={line}")]
        IObservable<VehiclesResponse> FetchAllVehiclesOfTypeAndLine(
            int type,
            string line,
            string apiKey = Keys.WARSAW_API_KEY,
            string resourceId = "f2e5503e-927d-4ad3-9500-4ab9e55deb59"
        );
    }
}
