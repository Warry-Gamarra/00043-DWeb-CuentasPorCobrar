using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Views
{
    public class VW_DevolucionPago
    {
        public int I_DevolucionPagoID { get; set; }
        public int I_PagoProcesID { get; set; }
        public decimal I_MontoPagoDev { get; set; }
        public DateTime? D_FecDevAprob { get; set; }
        public DateTime? D_FecDevPago { get; set; }
        public DateTime? D_FecProc { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }
        public bool B_Anulado { get; set; }
        public int N_NroSIAF { get; set; }
        public int I_EntidadFinanID { get; set; }
        public string C_CodOperacion { get; set; }
        public string C_Referencia { get; set; }
        public DateTime D_FecPago { get; set; }
        public string T_EntidadDesc { get; set; }
        public string C_CodClasificador { get; set; }
        public string T_ConceptoPagoDesc { get; set; }


        public static IEnumerable<VW_DevolucionPago> Find()
        {
            IEnumerable<VW_DevolucionPago> result;

            try
            {
                string s_command = @"SELECT DP.* FROM dbo.VW_DevolucionPago DP";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_DevolucionPago>(s_command, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static VW_DevolucionPago Find(int devolucionPagoID)
        {
            VW_DevolucionPago result;

            try
            {
                string s_command = @"SELECT DP.* FROM dbo.VW_DevolucionPago DP WHERE DP.I_DevolucionPagoID = @I_DevolucionPagoID";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.QuerySingleOrDefault<VW_DevolucionPago>(s_command, new { I_DevolucionPagoID = devolucionPagoID }, commandType: CommandType.Text);
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
