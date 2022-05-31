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

        public int I_MatAluID { get; set; }

        public int I_ProcesoID { get; set; }

        public string N_CodBanco { get; set; }

        public string C_CodAlu { get; set; }

        public string C_RcCod { get; set; }

        public string C_CodFac { get; set; }

        public string C_CodEsc { get; set; }

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

        public decimal I_MontoPagadoActual { get; set; }

        public decimal I_MontoPagadoSinMora { get; set; }

        public bool B_Pagado { get; set; }

        public DateTime D_FecCre { get; set; }

        public string C_CodServicio { get; set; }

        public string T_FacDesc { get; set; }

        public string T_DenomProg { get; set; }

        public static VW_CuotasPago FindByObligacionID(int obligacionID)
        {
            VW_CuotasPago result;

            try
            {
                string s_command = @"SELECT * FROM dbo.VW_CuotasPago_X_Ciclo c
                    WHERE c.I_ObligacionAluID = @I_ObligacionAluID";

                var parameters = new { I_ObligacionAluID = obligacionID };

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_CuotasPago>(s_command, parameters, commandType: CommandType.Text).FirstOrDefault();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static IEnumerable<VW_CuotasPago> FindByAlumno(int anio, int periodo, string codAlu, string codRc)
        {
            IEnumerable<VW_CuotasPago> result;

            try
            {
                string s_command = @"SELECT * FROM dbo.VW_CuotasPago_X_Ciclo c
                    WHERE c.I_Anio = @I_Anio AND c.I_Periodo = @I_Periodo AND c.C_CodAlu = @C_CodAlu AND c.C_RcCod = @C_CodRc";

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

        public static IEnumerable<VW_CuotasPago> GetPregrado(int anio, int? periodo, string codFac)
        {
            IEnumerable<VW_CuotasPago> result;

            try
            {
                codFac = String.IsNullOrEmpty(codFac) ? null : codFac;

                string s_command = @"SELECT * FROM dbo.VW_CuotasPago_X_Ciclo c 
                    WHERE c.I_Anio = @I_Anio AND c.I_Periodo = ISNULL(@I_Periodo, c.I_Periodo) AND c.C_Nivel = '1' AND
                        c.C_CodFac = ISNULL(@C_CodFac, c.C_CodFac)";

                var parameters = new { I_Anio = anio, I_Periodo = periodo, C_CodFac = codFac };

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

        public static IEnumerable<VW_CuotasPago> GetPosgrado(int anio, string codPosgrado)
        {
            IEnumerable<VW_CuotasPago> result;

            try
            {
                codPosgrado = String.IsNullOrEmpty(codPosgrado) ? null : codPosgrado;

                string s_command = @"SELECT * FROM dbo.VW_CuotasPago_General mat
                    WHERE 
	                    mat.I_Anio = @I_Anio AND
	                    mat.C_Nivel IN ('2', '3') AND
	                    mat.C_CodEsc = ISNULL(@C_CodEsc, mat.C_CodEsc) AND
	                    mat.B_Pagado = 0 AND
	                    mat.I_Prioridad = 1 AND
	                    DATEDIFF(DAY, GETDATE(), mat.D_FecVencto) >= 0
                    UNION
                    SELECT * FROM dbo.VW_CuotasPago_General pen
                    WHERE 
	                    pen.I_Anio <= @I_Anio AND 
	                    pen.C_Nivel IN ('2', '3') AND
	                    pen.C_CodEsc = ISNULL(@C_CodEsc, pen.C_CodEsc) AND
	                    pen.B_Pagado = 0 AND
	                    pen.I_Prioridad = 2 AND
	                    EXISTS (
		                    SELECT mat2.I_ObligacionAluID FROM dbo.VW_CuotasPago_General mat2 
		                    WHERE 
			                    mat2.I_MatAluID = pen.I_MatAluID AND 
			                    mat2.I_Anio = pen.I_Anio AND 
			                    mat2.I_Periodo = pen.I_Periodo AND
			                    mat2.I_Prioridad = 1 AND
			                    (
				                    (DATEDIFF(DAY, GETDATE(), mat2.D_FecVencto) >= 0 AND mat2.B_Pagado = 0) OR
				                    (mat2.B_Pagado = 1)
			                    )
                        )";

                var parameters = new { I_Anio = anio, C_CodEsc = codPosgrado };

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
