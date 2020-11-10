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
    public class TC_CatalogoOpcion
    {
        public int I_OpcionID { get; set; }
        public int I_ParametroID { get; set; }
        public string T_OpcionDesc { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }

        public static List<TC_CatalogoOpcion> FindByParametro(int I_ParametroID)
        {
            List<TC_CatalogoOpcion> result;

            try
            {
                string s_command = @"select p.* from TC_CatalogoOpcion p where p.I_ParametroID = @I_ParametroID and p.B_Eliminado = 0 ORDER BY p.T_OpcionDesc";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_CatalogoOpcion>(s_command, new { I_ParametroID = I_ParametroID }, commandType: CommandType.Text).ToList();
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
