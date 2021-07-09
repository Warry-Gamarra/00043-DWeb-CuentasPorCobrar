using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class TC_Concepto
    {
        public int I_ConceptoID { get; set; }

        public string T_ConceptoDesc { get; set; }

        public string T_Clasificador { get; set; }

        public string T_ClasifCorto { get; set; }

        public bool B_EsObligacion { get; set; }

        public bool B_EsPagoMatricula { get; set; }

        public bool B_EsPagoExtmp { get; set; }

        public bool? B_Fraccionable { get; set; }

        public bool? B_ConceptoGeneral { get; set; }

        public bool? B_AgrupaConcepto { get; set; }

        public int? I_TipoObligacion { get; set; }

        public bool B_Calculado { get; set; }

        public int I_Calculado { get; set; }

        public bool? B_GrupoCodRc { get; set; }

        public int? I_GrupoCodRc { get; set; }

        public bool? B_ModalidadIngreso { get; set; }

        public int? I_ModalidadIngresoID { get; set; }

        public bool B_ConceptoAgrupa { get; set; }

        public int? I_ConceptoAgrupaID { get; set; }

        public byte? N_NroPagos { get; set; }

        public bool? B_Porcentaje { get; set; }

        public string C_Moneda { get; set; }

        public decimal I_Monto { get; set; }

        public decimal I_MontoMinimo { get; set; }

        public string T_DescripcionLarga { get; set; }

        public string T_Documento { get; set; }

        public bool? B_Mora { get; set; }

        public bool B_Habilitado { get; set; }

        public bool B_Eliminado { get; set; }

        public int? I_UsuarioCre { get; set; }

        public DateTime? D_FecCre { get; set; }

        public int? I_UsuarioMod { get; set; }

        public DateTime? D_FecMod { get; set; }

        public static List<TC_Concepto> Find()
        {
            List<TC_Concepto> result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT c.* FROM TC_Concepto c WHERE c.B_Eliminado = 0";

                    result = _dbConnection.Query<TC_Concepto>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static List<TC_Concepto> Find(bool esObligacion)
        {
            List<TC_Concepto> result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT c.* FROM TC_Concepto c WHERE c.B_Eliminado = 0 AND c.B_EsObligacion = @B_EsObligacion";

                    result = _dbConnection.Query<TC_Concepto>(s_command, new { B_EsObligacion = esObligacion ? 1 : 0 }, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static TC_Concepto Find(int conceptoID)
        {
            TC_Concepto result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT c.* FROM TC_Concepto c WHERE I_ConceptoID = @I_ConceptoID AND c.B_Eliminado = 0";

                    result = _dbConnection.QuerySingleOrDefault<TC_Concepto>(s_command, new { I_ConceptoID = conceptoID }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }


        public ResponseData Insert(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_ConceptoID", dbType: DbType.Int32, value: this.I_ConceptoID);
                    parameters.Add(name: "T_ConceptoDesc", dbType: DbType.String, size: 250, value: this.T_ConceptoDesc);
                    parameters.Add(name: "T_Clasificador", dbType: DbType.String, size: 50, value: this.T_Clasificador);
                    parameters.Add(name: "I_Monto", dbType: DbType.Decimal, value: this.I_Monto);
                    parameters.Add(name: "I_MontoMinimo", dbType: DbType.Decimal, value: this.I_MontoMinimo);
                    parameters.Add(name: "B_EsPagoMatricula", dbType: DbType.Boolean, value: this.B_EsPagoMatricula);
                    parameters.Add(name: "B_EsPagoExtmp", dbType: DbType.Boolean, value: this.B_EsPagoExtmp);
                    parameters.Add(name: "B_ConceptoAgrupa", dbType: DbType.Boolean, value: this.B_ConceptoAgrupa);
                    parameters.Add(name: "B_Calculado", dbType: DbType.Boolean, value: this.B_Calculado);
                    parameters.Add(name: "I_Calculado", dbType: DbType.Int32, value: this.I_Calculado);
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecCre);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);
                    parameters.Add(name: "B_Mora", dbType: DbType.Boolean, value: this.B_Mora);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarConcepto", parameters, commandType: CommandType.StoredProcedure);

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

        public ResponseData Update(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_ConceptoID", dbType: DbType.Int32, value: this.I_ConceptoID);
                    parameters.Add(name: "T_ConceptoDesc", dbType: DbType.String, size: 250, value: this.T_ConceptoDesc);
                    parameters.Add(name: "T_Clasificador", dbType: DbType.String, size: 50, value: this.T_Clasificador);
                    parameters.Add(name: "I_Monto", dbType: DbType.Decimal, value: this.I_Monto);
                    parameters.Add(name: "I_MontoMinimo", dbType: DbType.Decimal, value: this.I_MontoMinimo);
                    parameters.Add(name: "B_EsPagoMatricula", dbType: DbType.Boolean, value: this.B_EsPagoMatricula);
                    parameters.Add(name: "B_EsPagoExtmp", dbType: DbType.Boolean, value: this.B_EsPagoExtmp);
                    parameters.Add(name: "B_ConceptoAgrupa", dbType: DbType.Boolean, value: this.B_ConceptoAgrupa);
                    parameters.Add(name: "B_Calculado", dbType: DbType.Boolean, value: this.B_Calculado);
                    parameters.Add(name: "I_Calculado", dbType: DbType.Int32, value: this.I_Calculado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);
                    parameters.Add(name: "B_Mora", dbType: DbType.Boolean, value: this.B_Mora);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarConcepto", parameters, commandType: CommandType.StoredProcedure);

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

        public ResponseData ChangeState(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_ConceptoID", dbType: DbType.Int32, value: this.I_ConceptoID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoConcepto", parameters, commandType: CommandType.StoredProcedure);

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
