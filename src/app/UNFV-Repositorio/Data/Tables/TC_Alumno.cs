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
    public class TC_Alumno
    {
        public string C_RcCod { get; set; }

        public string C_CodAlu { get; set; }

        public int I_PersonaID { get; set; }

        public string C_CodModIng { get; set; }

        public short? C_AnioIngreso { get; set; }

        public int? I_IdPlan { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }

        public static IEnumerable<TC_Alumno> GetAll()
        {
            IEnumerable<TC_Alumno> result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM TC_Alumno WHERE B_Eliminado = 0";

                    result = _dbConnection.Query<TC_Alumno>(command, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static TC_Alumno GetByID(string C_RcCod, string C_CodAlu)
        {
            TC_Alumno result;
            string command;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    command = "SELECT * FROM TC_Alumno WHERE B_Eliminado = 0 AND C_RcCod = @C_RcCod AND C_CodAlu = @C_CodAlu";

                    result = _dbConnection.QueryFirstOrDefault<TC_Alumno>(command, new { C_RcCod = C_RcCod, C_CodAlu = C_CodAlu }, commandType: CommandType.Text);
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
