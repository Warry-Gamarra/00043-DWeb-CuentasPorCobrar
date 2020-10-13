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
    public class TC_Periodo
    {
        public int I_PeriodoID { get; set; }
        public int? I_CuotaPagoID { get; set; }
        public short? N_Anio { get; set; }
        public DateTime? D_FecIni { get; set; }
        public DateTime? D_FecFin { get; set; }
        public bool B_Habilitado { get; set; }

        public static TC_Periodo FindByID(int I_PeriodoID)
        {
            TC_Periodo result;

            try
            {
                string s_command = @"select p.I_PeriodoID, p.I_CuotaPagoID, p.N_Anio, p.D_FecIni, p.D_FecFin, p.B_Habilitado from dbo.TC_Periodo p where p.I_PeriodoID = @I_PeriodoID";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TC_Periodo>(s_command, new { I_PeriodoID = I_PeriodoID }, commandType: CommandType.Text).FirstOrDefault();
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
