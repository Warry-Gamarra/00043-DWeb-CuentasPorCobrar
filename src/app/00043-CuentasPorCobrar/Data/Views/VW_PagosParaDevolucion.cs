using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Views
{
    public class VW_PagosParaDevolucion
    {
        public int I_TipoPagoID { get; set; }

        public int I_PagoBancoID { get; set; }

        public string C_CodOperacion {  get; set; }

        public string C_CodigoInterno { get; set; }

        public string C_CodDepositante { get; set; }

        public string T_NomDepositante { get; set; }

        public int I_EntidadFinanID { get; set; }

        public string T_EntidadDesc { get; set; }

        public int I_CtaDepositoID { get; set; }

        public string C_NumeroCuenta { get; set; }

        public DateTime D_FecPago { get; set; }

        public int I_Cantidad { get; set; }

        public string C_Moneda { get; set; }

        public string T_Concepto { get; set; }

        public string T_LugarPago { get; set; }

        public decimal I_MontoPago { get; set; }

        public decimal I_InteresMora { get; set; }

        public string T_InformacionAdicional { get; set; }

        public bool B_DevolucionPermitida {  get; set; }

        public static IEnumerable<VW_PagosParaDevolucion> FindByCodOperacion(int I_EntidadFinanID, string C_CodOperacion)
        {
            IEnumerable<VW_PagosParaDevolucion> result;
            DynamicParameters parameters;
            string s_command;

            try
            {
                s_command = "SELECT * FROM VW_PagosParaDevolucion p WHERE p.I_EntidadFinanID = @I_EntidadFinanID AND p.C_CodOperacion = @C_CodOperacion;";

                parameters = new DynamicParameters();

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: I_EntidadFinanID);
                    parameters.Add(name: "C_CodOperacion", dbType: DbType.String, value: C_CodOperacion);

                    result = _dbConnection.Query<VW_PagosParaDevolucion>(s_command, parameters, commandType: CommandType.Text, commandTimeout: 100);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static VW_PagosParaDevolucion FindByID(int I_PagoBancoID)
        {
            VW_PagosParaDevolucion result;
            DynamicParameters parameters;
            string s_command;

            try
            {
                s_command = "SELECT * FROM VW_PagosParaDevolucion p WHERE p.I_PagoBancoID = @I_PagoBancoID;";

                parameters = new DynamicParameters();

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_PagoBancoID", dbType: DbType.Int32, value: I_PagoBancoID);

                    result = _dbConnection.QueryFirst<VW_PagosParaDevolucion>(s_command, parameters, commandType: CommandType.Text, commandTimeout: 100);
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
