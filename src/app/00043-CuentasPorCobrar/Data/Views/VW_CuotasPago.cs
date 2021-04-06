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
    public class VW_CuotasPago
    {
        public int I_NroOrden { get; set; }

        public int I_ObligacionAluID { get; set; }

        public int I_ProcesoID { get; set; }

        public string N_CodBanco { get; set; }

        public string C_CodAlu { get; set; }

        public string C_CodRc { get; set; }

        public string C_CodFac { get; set; }

        public string T_Nombre { get; set; }

        public string T_ApePaterno { get; set; }

        public string T_ApeMaterno { get; set; }

        public int I_Anio { get; set; }

        public int I_Periodo { get; set; }

        public string C_Periodo { get; set; }

        public string T_Periodo { get; set; }

        public string T_ProcesoDesc { get; set; }

        public DateTime D_FecVencto { get; set; }

        public byte I_Prioridad { get; set; }

        public string C_Moneda { get; set; }

        public string C_Nivel { get; set; }

        public string C_TipoAlumno { get; set; }

        public decimal? I_MontoOblig { get; set; }

        public string C_CodOperacion { get; set; }

        public  DateTime? D_FecPago { get; set; }

        public string T_LugarPago { get; set; }

        public static IEnumerable<VW_CuotasPago> FindByAlumno(int anio, int periodo, string codAlu, string codRc)
        {
            IEnumerable<VW_CuotasPago> result;

            try
            {
                string s_command = @"SELECT * FROM dbo.VW_CuotasPago c
                    WHERE c.I_Anio = @I_Anio AND c.I_Periodo = @I_Periodo AND c.C_CodAlu = @C_CodAlu AND c.C_CodRc = @C_CodRc";

                var parameters = new { I_Anio = anio, I_Periodo = periodo, C_CodAlu = codAlu, C_CodRc = codRc };

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_CuotasPago>(s_command, parameters, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<VW_CuotasPago> GetPregrado(int anio, int periodo, string codFac, DateTime? fechaDesde, DateTime? fechaHasta)
        {
            IEnumerable<VW_CuotasPago> result;

            try
            {
                string s_command = @"SELECT * FROM dbo.VW_CuotasPago c 
                    WHERE c.I_Anio = @I_Anio AND c.I_Periodo = @I_Periodo AND
                        c.C_Nivel = '1' AND c.C_CodFac = ISNULL(@C_CodFac, C_CodFac)";

                if (fechaDesde.HasValue)
                {
                    s_command += " AND DATEDIFF(DAY, c.D_FecVencto, @D_FechaDesde) <= 0";
                }

                if (fechaHasta.HasValue)
                {
                    s_command += " AND DATEDIFF(DAY, c.D_FecVencto, @D_FechaHasta) >= 0";
                }

                var parameters = new { I_Anio = anio, I_Periodo = periodo, C_CodFac = codFac, D_FechaDesde = fechaDesde, D_FechaHasta = fechaHasta };

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_CuotasPago>(s_command, parameters, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<VW_CuotasPago> GetPosgrado(int anio, int periodo, DateTime? fechaDesde, DateTime? fechaHasta)
        {
            IEnumerable<VW_CuotasPago> result;

            try
            {
                string s_command = @"SELECT * FROM dbo.VW_CuotasPago c WHERE c.I_Anio = @I_Anio AND c.I_Periodo = @I_Periodo
                    AND c.C_Nivel IN ('2', '3')";

                if (fechaDesde.HasValue)
                {
                    s_command += " AND DATEDIFF(DAY, c.D_FecVencto, @D_FechaDesde) <= 0";
                }

                if (fechaHasta.HasValue)
                {
                    s_command += " AND DATEDIFF(DAY, c.D_FecVencto, @D_FechaHasta) >= 0";
                }

                var parameters = new { I_Anio = anio, I_Periodo = periodo, D_FechaDesde = fechaDesde, D_FechaHasta = fechaHasta };

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_CuotasPago>(s_command, parameters, commandType: CommandType.Text);
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
