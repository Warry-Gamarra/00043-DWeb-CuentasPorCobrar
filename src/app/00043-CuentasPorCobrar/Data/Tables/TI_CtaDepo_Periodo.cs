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
    public class TI_CtaDepo_Periodo
    {
        public int I_CtaDepoPerID { get; set; }
        public int I_CtaDepositoID { get; set; }
        public int I_PeriodoID { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }

        public static List<TI_CtaDepo_Periodo> FindAll()
        {
            List<TI_CtaDepo_Periodo> result;

            try
            {
                string s_command = @"SELECT c.* FROM dbo.TI_CtaDepo_Periodo c  WHERE B_Eliminado = 0;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TI_CtaDepo_Periodo>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static List<TI_CtaDepo_Periodo> FindByPeriodo(int I_PeriodoID)
        {
            List<TI_CtaDepo_Periodo> result;

            try
            {
                string s_command = @"select c.* from TI_CtaDepo_Periodo c where c.I_PeriodoID = @I_PeriodoID and c.B_Eliminado = 0";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TI_CtaDepo_Periodo>(s_command, new { I_PeriodoID = I_PeriodoID }, commandType: CommandType.Text).ToList();
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
