using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Procedures
{
    public class USP_S_ObtenerCuotaPago
    {
        public int I_ObligacionAluID { get; set; }

        public string C_CodAlu { get; set; }

        public string C_RcCod { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string C_Periodo { get; set; }

        public string T_Periodo { get; set; }

        public int I_ProcesoID { get; set; }

        public string T_ProcesoDesc { get; set; }

        public DateTime D_FecVencto { get; set; }

        public byte I_Prioridad { get; set; }

        public string N_CodBanco { get; set; }

        public decimal I_MontoOblig { get; set; }

        public decimal I_MontoPagadoActual { get; set; }

        public decimal I_MontoPagadoSinMora { get; set; }

        public bool B_Pagado { get; set; }

        public DateTime D_FecCre { get; set; }

        public static USP_S_ObtenerCuotaPago Execute(int obligacionID)
        {
            DynamicParameters parameters;
            USP_S_ObtenerCuotaPago result;

            try
            {
                string s_command = "EXEC USP_S_ObtenerCuotaPago @I_ObligacionAluID";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_ObligacionAluID", dbType: DbType.Int32, value: obligacionID);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ObtenerCuotaPago>(s_command, parameters, commandType: CommandType.Text).FirstOrDefault();
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
