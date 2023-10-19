using Data.Connection;
using Data.Views;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dapper;

namespace Data.Procedures
{
    public class USP_S_Listar_ObligacionesPendientes
    {
        public int I_NroOrden { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string C_CodRc { get; set; }

        public string C_CodAlu { get; set; }

        public string C_CodFac { get; set; }

        public string C_CodEsc { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public int I_ProcesoID { get; set; }

        public string C_Periodo { get; set; }

        public byte I_Prioridad { get; set; }

        public string N_CodBanco { get; set; }

        public string C_CodServicio { get; set; }

        public DateTime D_FecVencto { get; set; }

        public decimal I_MontoOblig { get; set; }

        public decimal I_MontoPagadoSinMora { get; set; }

        public static IEnumerable<USP_S_Listar_ObligacionesPendientes> ExecutePregrado(int anio, int nivel, int? periodo, string codFac)
        {
            IEnumerable<USP_S_Listar_ObligacionesPendientes> result;
            DynamicParameters parameters;

            try
            {
                codFac = String.IsNullOrEmpty(codFac) ? null : codFac;

                string s_command = "USP_S_Listar_ObligacionesPendientes_Pregrado";

                parameters = new DynamicParameters();

                parameters.Add(name: "I_Anio", dbType: DbType.Int32, value: anio);
                
                parameters.Add(name: "I_Nivel", dbType: DbType.Int32, value: nivel);

                parameters.Add(name: "I_Periodo", dbType: DbType.Int32, value: periodo);

                parameters.Add(name: "C_CodFac", dbType: DbType.String, value: codFac);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_Listar_ObligacionesPendientes>(s_command, parameters, commandType: CommandType.StoredProcedure, commandTimeout: 60);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<USP_S_Listar_ObligacionesPendientes> ExecutePosgrado(int anio, string codEsc)
        {
            IEnumerable<USP_S_Listar_ObligacionesPendientes> result;
            DynamicParameters parameters;

            try
            {
                codEsc = String.IsNullOrEmpty(codEsc) ? null : codEsc;

                string s_command = "USP_S_Listar_ObligacionesPendientes_Posgrado";

                parameters = new DynamicParameters();

                parameters.Add(name: "I_Anio", dbType: DbType.Int32, value: anio);

                parameters.Add(name: "C_CodEsc", dbType: DbType.String, value: codEsc);

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_Listar_ObligacionesPendientes>(s_command, parameters, commandType: CommandType.StoredProcedure, commandTimeout: 60);
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
