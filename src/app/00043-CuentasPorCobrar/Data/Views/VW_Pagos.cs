using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Views
{
    public class VW_Pagos
    {
        public int I_NroOrden { get; set; }
        public int I_CtaDepositoID { get; set; }
        public string C_NumeroCuenta { get; set; }
        public string C_CodOperacion { get; set; }
        public string C_CodDepositante { get; set; }
        public int I_PagoBancoID { get; set; }
        public string T_NomDepositante { get; set; }
        public DateTime D_FecPago { get; set; }
        public int I_Cantidad { get; set; }
        public string C_Periodo { get; set; }
        public string T_NomAlumno { get; set; }
        public int I_ObligacionAluID { get; set; }
        public int I_ProcesoID { get; set; }
        public int? I_CuotaPagoID { get; set; }
        public string C_CodAlu { get; set; }
        public string C_RcCod { get; set; }
        public int I_Anio { get; set; }
        public string T_Concepto { get; set; }
        public DateTime D_FecVencto { get; set; }
        public string C_Moneda { get; set; }
        public string T_LugarPago { get; set; }
        public decimal I_MontoPagado { get; set; }
        public string C_CodServicio { get; set; }
        public string C_Referencia { get; set; }
        public int I_EntidadFinanID { get; set; }
        public string T_EntidadDesc { get; set; }
        public string T_InformacionAdicional { get; set; }       

        public static IEnumerable<VW_Pagos> Find(int entRecaudaId, string codOperacion)
        {
            IEnumerable<VW_Pagos> result;

            try
            {
                string s_command = @"SELECT P.* FROM dbo.VW_Pagos P WHERE I_EntidadFinanID = @I_EntidadFinanID AND C_CodOperacion = @C_CodOperacion;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_Pagos>(s_command,
                                                            new
                                                            {
                                                                I_EntidadFinanID = entRecaudaId,
                                                                C_CodOperacion = codOperacion
                                                            },
                                                            commandType: System.Data.CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static VW_Pagos Find(int pagoBancoID)
        {
            VW_Pagos result = new VW_Pagos();

            try
            {
                string s_command = @"SELECT P.* FROM dbo.VW_Pagos P WHERE I_PagoBancoID = @I_PagoBancoID;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.QuerySingleOrDefault<VW_Pagos>(s_command, new { I_PagoBancoID = pagoBancoID }, commandType: System.Data.CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }


        public static IEnumerable<VW_Pagos> Find(int? entRecaudaId, int? dependenciaId, DateTime fecIni, DateTime fecFin)
        {
            IEnumerable<VW_Pagos> result;

            try
            {
                string s_command = @"SELECT P.*  FROM dbo.VW_Pagos P 
                                     WHERE DATEDIFF(day, @D_FechaIni, D_FecPago) >= 0 AND DATEDIFF(day, D_FecPago, @D_FechaFin) >= 0";

                if (dependenciaId.HasValue)
                    s_command += " AND I_DependenciaID = @I_DependenciaID ";

                if (entRecaudaId.HasValue)
                    s_command += " AND I_EntidadFinanID = @I_EntidadFinanID ";

                s_command += ";";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_Pagos>(s_command,
                        new
                        {
                            D_FechaIni = fecIni,
                            D_FechaFin = fecFin,
                            I_DependenciaID = dependenciaId,
                            I_EntidadFinanID = entRecaudaId,
                        }, commandType: System.Data.CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<VW_Pagos> FindPregrado(int? entRecaudaId, int? dependenciaId, DateTime fecIni, DateTime fecFin)
        {
            IEnumerable<VW_Pagos> result;

            try
            {
                string s_command = @"SELECT P.*  FROM dbo.VW_Pagos P 
                                     WHERE DATEDIFF(day, @D_FechaIni, D_FecPago) >= 0 AND DATEDIFF(day, D_FecPago, @D_FechaFin) >= 0 AND C_Nivel = '1'";

                if (dependenciaId.HasValue)
                    s_command += " AND I_DependenciaID = @I_DependenciaID ";

                if (entRecaudaId.HasValue)
                    s_command += " AND I_EntidadFinanID = @I_EntidadFinanID ";

                s_command += ";";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_Pagos>(s_command,
                        new
                        {
                            D_FechaIni = fecIni,
                            D_FechaFin = fecFin,
                            I_DependenciaID = dependenciaId,
                            I_EntidadFinanID = entRecaudaId,
                        }, commandType: System.Data.CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<VW_Pagos> FindPosgrado(int? entRecaudaId, int? dependenciaId, DateTime fecIni, DateTime fecFin)
        {
            IEnumerable<VW_Pagos> result;

            try
            {
                string s_command = @"SELECT P.*  FROM dbo.VW_Pagos P 
                                     WHERE DATEDIFF(day, @D_FechaIni, D_FecPago) >= 0 AND DATEDIFF(day, D_FecPago, @D_FechaFin) >= 0 AND C_Nivel IN ('2', '3') ";

                if (dependenciaId.HasValue)
                    s_command += " AND I_DependenciaID = @I_DependenciaID ";

                if (entRecaudaId.HasValue)
                    s_command += " AND I_EntidadFinanID = @I_EntidadFinanID ";

                s_command += ";";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_Pagos>(s_command,
                        new
                        {
                            D_FechaIni = fecIni,
                            D_FechaFin = fecFin,
                            I_DependenciaID = dependenciaId,
                            I_EntidadFinanID = entRecaudaId,
                        }, commandType: System.Data.CommandType.Text);
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
