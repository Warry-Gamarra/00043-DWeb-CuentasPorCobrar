using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class TC_RegimenEstudio
    {
        public string C_CodRegimenEst { get; set; }

        public string T_RegimenEstDesc { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }

        public IEnumerable<TC_RegimenEstudio> GetAll()
        {
            IEnumerable<TC_RegimenEstudio> result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM TC_RegimenEstudio WHERE B_Eliminado = 0";

                    result = _dbConnection.Query<TC_RegimenEstudio>(command, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }
    }
}
