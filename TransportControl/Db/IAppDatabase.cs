using System.Collections.Generic;
using System.Threading.Tasks;
using TransportControl.Models;

namespace TransportControl.Db
{
    public interface IAppDatabase
    {
        Task<bool> Insert(Line line);
        Task<IEnumerable<Line>> GetAll();
        Task Delete(Line line);
    }
}
