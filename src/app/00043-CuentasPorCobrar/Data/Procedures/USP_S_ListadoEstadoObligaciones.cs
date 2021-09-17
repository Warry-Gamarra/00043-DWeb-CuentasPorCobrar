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
    public class USP_S_ListadoEstadoObligaciones
    {
        public int I_MatAluID { get; set; }

        public int I_ObligacionAluID { get; set; }

        public string C_CodAlu { get; set; }

        public string C_RcCod { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public string N_Grado { get; set; }

        public string C_CodFac { get; set; }

        public string T_FacDesc { get; set; }

        public string C_CodEsc { get; set; }

        public string T_EscDesc { get; set; }

        public string T_DenomProg { get; set; }

        public bool B_Ingresante { get; set; }

        public int I_CredDesaprob { get; set; }

        public int I_Anio { get; set; }

        public string T_Periodo { get; set; }

        public string T_ProcesoDesc { get; set; }

        public decimal? I_MontoOblig { get; set; }

        public DateTime? D_FecVencto { get; set; }

        public bool? B_Pagado { get; set; }

        public decimal? I_MontoPagadoActual { get; set; }

        public DateTime D_FecCre { get; set; }

        public DateTime? D_FecMod { get; set; }

        public static IEnumerable<USP_S_ListadoEstadoObligaciones> Execute(USP_S_ListadoEstadoObligaciones_Parameters pr)
        {
            IEnumerable<USP_S_ListadoEstadoObligaciones> result;
            DynamicParameters parameters;
            string s_command;

            try
            {
                s_command = "USP_S_ListadoEstadoObligaciones";

                parameters = new DynamicParameters();

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "B_EsPregrado", dbType: DbType.Boolean, value: pr.B_EsPregrado);
                    parameters.Add(name: "I_Anio", dbType: DbType.Int32, value: pr.I_Anio);
                    parameters.Add(name: "I_Periodo", dbType: DbType.Int32, value: pr.I_Periodo);
                    parameters.Add(name: "C_CodFac", dbType: DbType.String, value: pr.C_CodFac);
                    parameters.Add(name: "C_CodEsc", dbType: DbType.String, value: pr.C_CodEsc);
                    parameters.Add(name: "C_RcCod", dbType: DbType.String, value: pr.C_RcCod);
                    parameters.Add(name: "B_Ingresante", dbType: DbType.Boolean, value: pr.B_Ingresante);
                    parameters.Add(name: "B_ObligacionGenerada", dbType: DbType.Boolean, value: pr.B_ObligacionGenerada);
                    parameters.Add(name: "B_Pagado", dbType: DbType.Boolean, value: pr.B_Pagado);
                    parameters.Add(name: "F_FecIni", dbType: DbType.Date, value: pr.F_FecIni);
                    parameters.Add(name: "F_FecFin", dbType: DbType.Date, value: pr.F_FecFin);
                    parameters.Add(name: "B_MontoPagadoDiff", dbType: DbType.Boolean, value: pr.B_MontoPagadoDiff);

                    result = _dbConnection.Query<USP_S_ListadoEstadoObligaciones>(s_command, parameters, commandType: CommandType.StoredProcedure);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }
    }

    public class USP_S_ListadoEstadoObligaciones_Parameters
    {
        public bool B_EsPregrado { get; set; }
        public int I_Anio { get; set; }
        public int? I_Periodo { get; set; }
        public string C_CodFac { get; set; }
        public string C_CodEsc { get; set; }
        public string C_RcCod { get; set; }
        public bool? B_Ingresante { get; set; }
        public bool? B_ObligacionGenerada { get; set; }
        public bool? B_Pagado { get; set; }
        public DateTime? F_FecIni { get; set; }
        public DateTime? F_FecFin { get; set; }
        public bool? B_MontoPagadoDiff { get; set; }
    }
}
