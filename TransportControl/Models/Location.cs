using Plugin.Geolocator.Abstractions;
using SQLite;

namespace TransportControl.Models
{
    public class Location
    {
        [PrimaryKey, AutoIncrement]
        public int Id { get; set; }

        [Indexed]
        public string Name { get; set; }

        public double Lat { get; set; }

        public double Lon { get; set; }

        [Ignore]
        public Position Position => new Position(Lat, Lon);
    }
}
