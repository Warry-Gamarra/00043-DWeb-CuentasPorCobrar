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
    public class USP_U_ActualizarConceptoPago
    {
        public int I_ConcPagID { get; set; }
        public int I_ProcesoID { get; set; }
        public int I_ConceptoID { get; set; }
        public bool? B_Fraccionable { get; set; }
        public bool? B_ConceptoGeneral { get; set; }
        public bool? B_AgrupaConcepto { get; set; }
        public int? I_AlumnosDestino { get; set; }
        public int? I_GradoDestino { get; set; }
        public int? I_TipoObligacion { get; set; }
        public string T_Clasificador { get; set; }
        public string C_CodTasa { get; set; }
        public bool? B_Calculado { get; set; }
        public int? I_Calculado { get; set; }
        public bool? B_AnioPeriodo { get; set; }
        public int? I_Anio { get; set; }
        public int? I_Periodo { get; set; }
        public bool? B_Especialidad { get; set; }
        public char? C_CodRc { get; set; }
        public bool? B_Dependencia { get; set; }
        public int? C_DepCod { get; set; }
        public bool? B_GrupoCodRc { get; set; }
        public int? I_GrupoCodRc { get; set; }
        public bool? B_ModalidadIngreso { get; set; }
        public int? I_ModalidadIngresoID { get; set; }
        public bool? B_ConceptoAgrupa { get; set; }
        public int? I_ConceptoAgrupaID { get; set; }
        public bool? B_ConceptoAfecta { get; set; }
        public int? I_ConceptoAfectaID { get; set; }
        public int? N_NroPagos { get; set; }
        public bool? B_Porcentaje { get; set; }
        public decimal? M_Monto { get; set; }
        public decimal? M_MontoMinimo { get; set; }
        public string T_DescripcionLarga { get; set; }
        public string T_Documento { get; set; }
        public bool B_Habilitado { get; set; }
        public int I_UsuarioMod { get; set; }

        public ResponseData Execute()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_U_ActualizarConceptoPago";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_ConcPagID", dbType: DbType.Int32, value: this.I_ConcPagID);
                    parameters.Add(name: "I_ProcesoID", dbType: DbType.Int32, value: this.I_ProcesoID);
                    parameters.Add(name: "I_ConceptoID", dbType: DbType.Int32, value: this.I_ConceptoID);
                    parameters.Add(name: "B_Fraccionable", dbType: DbType.Boolean, value: this.B_Fraccionable);
                    parameters.Add(name: "B_ConceptoGeneral", dbType: DbType.Boolean, value: this.B_ConceptoGeneral);
                    parameters.Add(name: "B_AgrupaConcepto", dbType: DbType.Boolean, value: this.B_AgrupaConcepto);
                    parameters.Add(name: "I_AlumnosDestino", dbType: DbType.Int32, value: this.I_AlumnosDestino);
                    parameters.Add(name: "I_GradoDestino", dbType: DbType.Int32, value: this.I_GradoDestino);
                    parameters.Add(name: "I_TipoObligacion", dbType: DbType.Int32, value: this.I_TipoObligacion);
                    parameters.Add(name: "T_Clasificador", dbType: DbType.String, value: this.T_Clasificador);
                    parameters.Add(name: "C_CodTasa", dbType: DbType.String, value: this.C_CodTasa);
                    parameters.Add(name: "B_Calculado", dbType: DbType.Boolean, value: this.B_Calculado);
                    parameters.Add(name: "I_Calculado", dbType: DbType.Int32, value: this.I_Calculado);
                    parameters.Add(name: "B_AnioPeriodo", dbType: DbType.Boolean, value: this.B_AnioPeriodo);
                    parameters.Add(name: "I_Anio", dbType: DbType.Int32, value: this.I_Anio);
                    parameters.Add(name: "I_Periodo", dbType: DbType.Int32, value: this.I_Periodo);
                    parameters.Add(name: "B_Especialidad", dbType: DbType.Boolean, value: this.B_Especialidad);
                    parameters.Add(name: "C_CodRc", dbType: DbType.String, value: this.C_CodRc, size: 3);
                    parameters.Add(name: "B_Dependencia", dbType: DbType.Boolean, value: this.B_Dependencia);
                    parameters.Add(name: "C_DepCod", dbType: DbType.Int32, value: this.C_DepCod);
                    parameters.Add(name: "B_GrupoCodRc", dbType: DbType.Boolean, value: this.B_GrupoCodRc);
                    parameters.Add(name: "I_GrupoCodRc", dbType: DbType.Int32, value: this.I_GrupoCodRc);
                    parameters.Add(name: "B_ModalidadIngreso", dbType: DbType.Boolean, value: this.B_ModalidadIngreso);
                    parameters.Add(name: "I_ModalidadIngresoID", dbType: DbType.Int32, value: this.I_ModalidadIngresoID);
                    parameters.Add(name: "B_ConceptoAgrupa", dbType: DbType.Boolean, value: this.B_ConceptoAgrupa);
                    parameters.Add(name: "I_ConceptoAgrupaID", dbType: DbType.Int32, value: this.I_ConceptoAgrupaID);
                    parameters.Add(name: "B_ConceptoAfecta", dbType: DbType.Boolean, value: this.B_ConceptoAfecta);
                    parameters.Add(name: "I_ConceptoAfectaID", dbType: DbType.Int32, value: this.I_ConceptoAfectaID);
                    parameters.Add(name: "N_NroPagos", dbType: DbType.Int32, value: this.N_NroPagos);
                    parameters.Add(name: "B_Porcentaje", dbType: DbType.Boolean, value: this.B_Porcentaje);
                    parameters.Add(name: "M_Monto", dbType: DbType.Decimal, value: this.M_Monto);
                    parameters.Add(name: "M_MontoMinimo", dbType: DbType.Decimal, value: this.M_MontoMinimo);
                    parameters.Add(name: "T_DescripcionLarga", dbType: DbType.String, value: this.T_DescripcionLarga);
                    parameters.Add(name: "T_Documento", dbType: DbType.String, value: this.T_Documento);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "I_UsuarioMod", dbType: DbType.Int32, value: this.I_UsuarioMod);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute(s_command, parameters, commandType: CommandType.StoredProcedure);

                    result.Value = parameters.Get<bool>("B_Result");
                    result.Message = parameters.Get<string>("T_Message");
                }
            }
            catch (Exception ex)
            {
                result.Value = false;
                result.Message = ex.Message;
            }

            return result;
        }
    }
}
