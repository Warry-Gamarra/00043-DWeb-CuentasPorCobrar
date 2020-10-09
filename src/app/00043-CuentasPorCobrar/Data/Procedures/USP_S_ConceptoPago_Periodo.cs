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
    public class USP_S_ConceptoPago_Periodo
    {
        public int I_ConcPagPerID { get; set; }
        public int I_ConceptoID { get; set; }
        public int B_Fraccionable { get; set; }
        public int B_ConceptoGeneral { get; set; }
        public int B_AgrupaConcepto { get; set; }
        public int I_AlumnosDestino { get; set; }
        public int I_GradoDestino { get; set; }
        public int I_TipoObligacion { get; set; }
        public int I_PeriodoID { get; set; }
        public int T_Clasificador { get; set; }
        public int T_Clasificador5 { get; set; }
        public int B_Calculado { get; set; }
        public int I_Calculado { get; set; }
        public int B_AnioPeriodo { get; set; }
        public int I_Anio { get; set; }
        public int I_Periodo { get; set; }
        public int B_Especialidad { get; set; }
        public int C_CodRc { get; set; }
        public int B_Dependencia { get; set; }
        public int C_DepCod { get; set; }
        public int B_GrupoCodRc { get; set; }
        public int I_GrupoCodRc { get; set; }
        public int B_ModalidadIngreso { get; set; }
        public int I_ModalidadIngresoID { get; set; }
        public int B_ConceptoAgrupa { get; set; }
        public int I_ConceptoAgrupaID { get; set; }
        public int B_ConceptoAfecta { get; set; }
        public int I_ConceptoAfectaID { get; set; }
        public int N_NroPagos { get; set; }
        public int B_Porcentaje { get; set; }
        public int M_Monto { get; set; }
        public int M_MontoMinimo { get; set; }
        public int T_DescripcionLarga { get; set; }
        public int T_Documento { get; set; }
        public int B_Habilitado { get; set; }

        public static List<USP_S_ConceptoPago_Periodo> Execute()
        {
            List<USP_S_ConceptoPago_Periodo> lista;
            string s_command;

            try
            {
                s_command = @"EXEC USP_S_ConceptoPago_Periodo;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    lista = new List<USP_S_ConceptoPago_Periodo>();

                    foreach (var item in _dbConnection.Query<USP_S_ConceptoPago_Periodo>(s_command, commandType: CommandType.StoredProcedure))
                    {
                        lista.Add(item);
                    }
                }
            }
            catch (Exception)
            {
                throw;
            }

            return lista;
        }
    }
}
