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
    public class PagoObligacionDetalle
    {
        public string C_CodOperacion { get; set; }

        public DateTime? D_FecPago { get; set; }

        public string T_LugarPago { get; set; }

        public static IEnumerable<PagoObligacionDetalle> FindByObligacionDetId(int I_ObligacionAluDetID)
        {
            string s_command;
            IEnumerable<PagoObligacionDetalle> result;
            DynamicParameters parameters;

            try
            {
                s_command = @"SELECT pb.C_CodOperacion, pb.D_FecPago, pb.T_LugarPago FROM dbo.TRI_PagoProcesadoUnfv pr
                    INNER JOIN dbo.TR_PagoBanco pb ON pb.I_PagoBancoID = pr.I_PagoBancoID
                    WHERE pr.I_ObligacionAluDetID = @I_ObligacionAluDetID AND pr.B_Anulado = 0 AND pb.B_Anulado = 0";

                parameters = new DynamicParameters();
                parameters.Add(name: "I_ObligacionAluDetID", dbType: DbType.Int32, value: I_ObligacionAluDetID);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<PagoObligacionDetalle>(s_command, parameters, commandType: CommandType.Text);
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
