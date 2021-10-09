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
    public class VW_ObligacionesPagadas
    {
        public int I_MatAluID { get; set; }

        public string C_CodAlu { get; set; }

        public string C_RcCod { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public int I_ProcesoID { get; set; }

        public string T_ProcesoDesc { get; set; }

        public int I_ObligacionAluID { get; set; }

        public decimal I_MontoOblig { get; set; }

        public int I_ObligacionAluDetID { get; set; }

        public int I_ConcPagID { get; set; }

        public string T_ConceptoPagoDesc { get; set; }

        public decimal I_Monto { get; set; }

        public DateTime D_FecVencto { get; set; }

        public int? I_TipoDocumento { get; set; }

        public string T_DescDocumento { get; set; }

        public decimal I_MontoPagado { get; set; }

        public int I_PagoBancoID { get; set; }

        public int I_EntidadFinanID { get; set; }

        public string T_EntidadDesc { get; set; }

        public int I_CtaDepositoID { get; set; }

        public string C_NumeroCuenta { get; set; }

        public string C_CodOperacion { get; set; }

        public DateTime D_FecPago { get; set; }

        public string T_LugarPago { get; set; }

        public DateTime D_FecCre { get; set; }

        public string T_Observacion { get; set; }

        public byte I_Prioridad { get; set; }

        public static IEnumerable<VW_ObligacionesPagadas> FindByObligacion(int idObligacion)
        {
            string s_command;
            IEnumerable<VW_ObligacionesPagadas> result;
            DynamicParameters parameters;

            try
            {
                s_command = @"SELECT b.* FROM dbo.VW_ObligacionesPagadas b
                    WHERE b.I_ObligacionAluID = @I_ObligacionAluID
                    ORDER BY I_Prioridad, T_ConceptoPagoDesc, D_FecVencto, D_FecPago";

                parameters = new DynamicParameters();

                parameters.Add(name: "I_ObligacionAluID", dbType: DbType.Int32, value: idObligacion);
                
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_ObligacionesPagadas>(s_command, parameters, commandType: CommandType.Text);
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
