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
    public class TC_Escuela
    {
        public string C_CodEsc { get; set; }

        public string C_CodFac { get; set; }

        public string T_EscDesc { get; set; }

        public string T_EscAbrev { get; set; }

        public string C_Tipo { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }

        public static IEnumerable<TC_Escuela> GetByFac(string codFac)
        {
            IEnumerable<TC_Escuela> result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM TC_Escuela WHERE B_Eliminado = 0 AND C_CodFac = @C_CodFac";

                    result = _dbConnection.Query<TC_Escuela>(command, new { C_CodFac = codFac }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static TC_Escuela GetByID(string codEsc, string codFac)
        {
            TC_Escuela result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM TC_Escuela WHERE B_Eliminado = 0 AND C_CodEsc = @C_CodEsc AND C_CodFac = @C_CodFac";

                    result = _dbConnection.QueryFirstOrDefault<TC_Escuela>(command, new { C_CodEsc = codEsc, C_CodFac = codFac }, commandType: CommandType.Text);
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
