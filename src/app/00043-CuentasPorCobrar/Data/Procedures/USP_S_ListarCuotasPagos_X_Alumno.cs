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
    public class USP_S_ListarCuotasPagos_X_Alumno
    {
        public int I_NroOrden { get; set; }

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

        public bool B_Pagado { get; set; }

        public DateTime D_FecCre { get; set; }

        public decimal I_MontoPagadoActual { get; set; }

        public decimal I_MontoPagadoSinMora { get; set; }

        public static IEnumerable<USP_S_ListarCuotasPagos_X_Alumno> Execute(int anio, int periodo, string codAlu, string codRc)
        {
            IEnumerable<USP_S_ListarCuotasPagos_X_Alumno> result;

            try
            {
                string s_command = "EXEC USP_S_ListarCuotasPagos_X_Alumno @I_Anio = @I_Anio, @I_Periodo = @I_Periodo, @C_CodAlu = @C_CodAlu, @C_RcCod = @C_RcCod;";

                var parameters = new { I_Anio = anio, I_Periodo = periodo, C_CodAlu = codAlu, C_RcCod = codRc };

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ListarCuotasPagos_X_Alumno>(s_command, parameters, commandType: CommandType.Text);
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
