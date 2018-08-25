using Newtonsoft.Json;
using System.Collections.Generic;

namespace TransportControl.Models
{
    public class VehiclesResponse
    {
        [JsonProperty("result")]
        public List<Vehicle> Result { get; set; }
    }
}
