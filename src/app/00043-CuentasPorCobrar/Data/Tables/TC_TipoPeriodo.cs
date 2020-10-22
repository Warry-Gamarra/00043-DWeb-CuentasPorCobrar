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
    public class TC_TipoPeriodo
    {
        public int I_TipoPeriodoID { get; set; }
        public string T_TipoPerDesc { get; set; }
        public int I_Prioridad { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int I_UsuarioCre { get; set; }
        public DateTime D_FecCre { get; set; }
        public int I_UsuarioMod { get; set; }
        public DateTime D_FecMod { get; set; }

        public static List<TC_TipoPeriodo> FindAll()
        {
            List<TC_TipoPeriodo> result;

            try
            {
                string s_command = @"select t.* from dbo.TC_TipoPeriodo t";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_TipoPeriodo>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static TC_TipoPeriodo FindByID(int I_TipoPeriodoID)
        {
            TC_TipoPeriodo result;

            try
            {
                string s_command = @"select t.* from dbo.TC_TipoPeriodo t where t.I_TipoPeriodoID = @I_TipoPeriodoID";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_TipoPeriodo>(s_command, new { I_TipoPeriodoID  = I_TipoPeriodoID }, commandType: CommandType.Text).FirstOrDefault();
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
