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
    public class USP_S_CantidadDePagosRegistrados_X_Dia
    {
        public int I_Dia { get; set; }
        public int Enero { get; set; }
        public int Febrero { get; set; }
        public int Marzo { get; set; }
        public int Abril { get; set; }
        public int Mayo { get; set; }
        public int Junio { get; set; }
        public int Julio { get; set; }
        public int Agosto { get; set; }
        public int Setiembre { get; set; }
        public int Octubre { get; set; }
        public int Noviembre { get; set; }
        public int Diciembre { get; set; }

        public static IEnumerable<USP_S_CantidadDePagosRegistrados_X_Dia> Execute(int anio, int tipoPago, int? entidadFinanID, int? ctaDepositoID, int? condicionPagoID)
        {
            IEnumerable<USP_S_CantidadDePagosRegistrados_X_Dia> result;
            DynamicParameters parameters;
            string s_command;

            try
            {
                s_command = "USP_S_CantidadDePagosRegistrados_X_Dia";

                parameters = new DynamicParameters();

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_Anio", dbType: DbType.Int32, value: anio);

                    parameters.Add(name: "I_TipoPagoID", dbType: DbType.Int32, value: tipoPago);

                    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: entidadFinanID);

                    parameters.Add(name: "I_CtaDepositoID", dbType: DbType.Int32, value: ctaDepositoID);

                    parameters.Add(name: "I_CondicionPagoID", dbType: DbType.Int32, value: condicionPagoID);

                    result = _dbConnection.Query<USP_S_CantidadDePagosRegistrados_X_Dia>(s_command, parameters, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result.OrderBy(x => x.I_Dia);
        }
    }
}
