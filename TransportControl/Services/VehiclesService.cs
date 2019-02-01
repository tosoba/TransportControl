using Refit;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Reactive.Linq;
using System.Threading;
using System.Threading.Tasks;
using TransportControl.Api;
using TransportControl.Models;

namespace TransportControl.Services
{
    public class VehiclesService : IVehiclesService
    {
        private const string apiBaseAddress = "https://api.um.warszawa.pl/api/action";

        private IVehiclesApiClient client;

        public VehiclesService()
        {
#if DEBUG
            var debugHandler = new DebugDelegatingHandler(new HttpClientHandler());
            var httpClient = new HttpClient(debugHandler)
            {
                BaseAddress = new Uri(apiBaseAddress)
            };
            client = RestService.For<IVehiclesApiClient>(httpClient);
#else
                client = RestService.For<IApiClient>(apiBaseAddress);
#endif
        }

        public IObservable<List<Vehicle>> FetchVehicles(int type, string line = null)
        {
            if (line == null)
            {
                return client.FetchAllVehiclesOfType(type).Select(response => response.Result);
            }
            else
            {
                return client.FetchAllVehiclesOfTypeAndLine(type, line).Select(response => response.Result);
            }
        }
    }

    internal class DebugDelegatingHandler : DelegatingHandler
    {
        public DebugDelegatingHandler(HttpMessageHandler innerHandler) : base(innerHandler) { }

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken) => base.SendAsync(request, cancellationToken);
    }
}
