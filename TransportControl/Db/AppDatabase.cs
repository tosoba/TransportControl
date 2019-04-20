using SQLite;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using TransportControl.Models;

namespace TransportControl.Db
{
    public class AppDatabase : IAppDatabase
    {
        private static readonly string databasePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "TransportControl.db");

        private static readonly Lazy<SQLiteAsyncConnection> connection = new Lazy<SQLiteAsyncConnection>(() => new SQLiteAsyncConnection(databasePath));

        private static SQLiteAsyncConnection Connection => connection.Value;

        private static async Task CreateTables()
        {
            await Connection.CreateTablesAsync(CreateFlags.None, typeof(Line), typeof(Location));
        }

        public AppDatabase()
        {
            Task.Run(async () =>
            {
                await CreateTables();
            });
        }

        public async Task<bool> InsertLine(Line line)
        {
            var query = Connection.Table<Line>().Where(l => l.Symbol == line.Symbol);
            var result = await query.ToListAsync();

            if (!result.Any())
            {
                await Connection.InsertAsync(line);
                return true;
            }
            return false;
        }

        public async Task<IEnumerable<Line>> GetAllLines() => await Connection.Table<Line>().ToListAsync();

        public async Task DeleteLine(Line line) => await Connection.DeleteAsync(line);

        public async Task<IEnumerable<Line>> FilterFavourites(IEnumerable<Line> lines)
        {
            var symbols = lines.Select(l => l.Symbol);
            var query = Connection.Table<Line>().Where(l => symbols.Contains(l.Symbol));
            return await query.ToListAsync();
        }

        public async Task InsertLocation(Location location) => await Connection.InsertAsync(location);

        public async Task<IEnumerable<Location>> GetAllLocations() => await Connection.Table<Location>().ToListAsync();

        public async Task DeleteLocation(Location location) => await Connection.DeleteAsync(location); 
    }
}
