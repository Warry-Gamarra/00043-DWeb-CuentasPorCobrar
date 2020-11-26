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
    public class TC_DependenciaUnfv
    {
        public int I_DependenciaID { get; set; }

        public string T_DepDesc { get; set; }

        public string C_DepCod { get; set; }

        public string C_DepCodPl { get; set; }

        public string T_DepAbrev { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }

        public IEnumerable<TC_DependenciaUnfv> GetAll()
        {
            IEnumerable<TC_DependenciaUnfv> result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM TC_DependenciaUnfv WHERE B_Eliminado = 0";

                    result = _dbConnection.Query<TC_DependenciaUnfv>(command, commandType: CommandType.Text);
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
