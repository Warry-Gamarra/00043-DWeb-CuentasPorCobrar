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
    public class TC_CategoriaPago
    {
        public int I_CatPagoID { get; set; }
        public string T_CatPagoDesc { get; set; }
        public int I_Prioridad { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }

        public static List<TC_CategoriaPago> FindAll()
        {
            List<TC_CategoriaPago> result;

            try
            {
                string s_command = @"select t.* from dbo.TC_CategoriaPago t  WHERE B_Eliminado = 0;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_CategoriaPago>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static TC_CategoriaPago FindByID(int I_CatPagoID)
        {
            TC_CategoriaPago result;

            try
            {
                string s_command = @"select t.* from dbo.TC_CategoriaPago t where t.I_CatPagoID = @I_CatPagoID";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_CategoriaPago>(s_command, new { I_CatPagoID = I_CatPagoID }, commandType: CommandType.Text).FirstOrDefault();
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
