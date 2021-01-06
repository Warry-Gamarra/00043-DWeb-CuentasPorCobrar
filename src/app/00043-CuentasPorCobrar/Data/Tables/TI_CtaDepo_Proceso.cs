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
    public class TI_CtaDepo_Proceso
    {
        public int I_CtaDepoProID { get; set; }
        public int I_CtaDepositoID { get; set; }
        public int I_ProcesoID { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }

        public static List<TI_CtaDepo_Proceso> FindAll()
        {
            List<TI_CtaDepo_Proceso> result;

            try
            {
                string s_command = @"SELECT c.* FROM dbo.TI_CtaDepo_Proceso c  WHERE B_Eliminado = 0;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TI_CtaDepo_Proceso>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static List<TI_CtaDepo_Proceso> FindByProceso(int I_ProcesoID)
        {
            List<TI_CtaDepo_Proceso> result;

            try
            {
                string s_command = @"select c.* from TI_CtaDepo_Proceso c where c.I_ProcesoID = @I_ProcesoID and c.B_Eliminado = 0";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TI_CtaDepo_Proceso>(s_command, new { I_ProcesoID = I_ProcesoID }, commandType: CommandType.Text).ToList();
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
