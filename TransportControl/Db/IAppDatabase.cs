using System.Collections.Generic;
using System.Threading.Tasks;
using TransportControl.Models;

namespace TransportControl.Db
{
    public interface IAppDatabase
    {
        Task<bool> InsertLine(Line line);
        Task<IEnumerable<Line>> GetAllLines();
        Task DeleteLine(Line line);
        Task<IEnumerable<Line>> FilterFavourites(IEnumerable<Line> lines);

        Task InsertLocation(Location location);
        Task<IEnumerable<Location>> GetAllLocations();
        Task DeleteLocation(Location location);
    }
}
