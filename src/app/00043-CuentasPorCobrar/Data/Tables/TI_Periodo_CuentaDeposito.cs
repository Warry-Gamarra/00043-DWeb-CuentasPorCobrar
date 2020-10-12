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
    public class TI_Periodo_CuentaDeposito
    {
        public int I_PeriodoID { get; set; }
        public int I_CtaDepID { get; set; }

        public static List<TI_Periodo_CuentaDeposito> FindByPeriodoID(int I_PeriodoID)
        {
            List<TI_Periodo_CuentaDeposito> result;

            try
            {
                string s_command = @"select c.I_PeriodoID, c.I_CtaDepID from dbo.TI_Periodo_CuentaDeposito c WHERE c.I_PeriodoID = @I_PeriodoID";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TI_Periodo_CuentaDeposito>(s_command, new { I_PeriodoID = I_PeriodoID }, commandType: CommandType.Text).ToList();
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
